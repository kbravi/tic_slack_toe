class Game < ApplicationRecord

  # Columns
  # id: Primary Key
  # team_id: The Slack team that this game is played in
  # channel_identifier: The Slack channel that this game is played in
  # player1_identifier: Player 1 - supports two players
  # player2_identifier: Player 2 - supports two players
  # complete: To denote if the game is complete
  # winner_identifier: Can be set to the values player1_identifier, or player2_identifier, or neither
  # moves_count: Caches the count of moves in the game - uses counter_cache on the associated moves model

  BOARD_SIZE = 3 # Can set size of the Tic Tac Toe board.
  MAX_MOVES = BOARD_SIZE**2
  DEFAULT_BUTTON_TEXT = ":white_large_square:" # Unplayed Tile
  PLAYER1_BUTTON_TEXT = ":x:" # Tile claimed by Player 1
  PLAYER2_BUTTON_TEXT = ":o:" # Tile claimed by Player 2
  ACTION_CALLBACK_KEY = "tic-slack-toe-game" # Callback to detect tile button interactions

  belongs_to :team
  has_many :moves, :dependent => :destroy

  scope :completed, -> { where(complete: true) }
  scope :active, -> { where(complete: false) }

  validates_presence_of :team_id, :channel_identifier
  validates_presence_of :player1_identifier, :player2_identifier, :challenger_identifier

  validates_uniqueness_of :channel_identifier, conditions: -> { where(complete: false) }

  validate :bound_moves_count, :different_players, :winner_played

  before_save :mark_complete_if_necessary

  # All winning combinations in a game of size BOARD_SIZE
  def self.winner_combinations
    winning_moves = Array.new
    [*1..BOARD_SIZE].each do |row|
      winning_moves <<  [*1..BOARD_SIZE].map{|col| [row, col]}
      winning_moves <<  [*1..BOARD_SIZE].map{|col| [col, row]}
    end
    winning_moves <<  [*1..BOARD_SIZE].map{|row_col| [row_col, row_col]}
    winning_moves <<  [*1..BOARD_SIZE].map{|row_col| [row_col, BOARD_SIZE - row_col + 1]}
    return winning_moves
  end

  # Player that needs to play next
  # Whoever plays first is assigned player1. Players take alternate turns. This ensures that.  #
  def next_player
    (moves_by_player[:player1].size == moves_by_player[:player2].size) ? self.player1_identifier : self.player2_identifier
  end

  # The player in (player1_identifier, player2_identifier) that was challenged by challenger_identifier
  def defendent_identifier
    (self.challenger_identifier == self.player1_identifier) ? self.player2_identifier : self.player1_identifier
  end

  # Game ends when maximum number of moves are played, or if winner was declared
  def game_over?
    return (self.moves_count >= MAX_MOVES or winner_identifier.present?)
  end

  # Collect moves and group by player1 and player2
  def moves_by_player
    player1_moves = self.moves.select{|x| x.player1_move}
    player2_moves = self.moves.select{|x| x.player2_move}
    return {:player1 => player1_moves, :player2 => player2_moves}
  end

  # Evaluate the board and look for winning combinations
  # Mark winners if player1 or player2 has a winning combination
  def evaluate_board_for_results
    player1_move_positions = self.moves_by_player[:player1].map{|move| [move.row, move.column]}
    player2_move_positions = self.moves_by_player[:player2].map{|move| [move.row, move.column]}
    if Game.winner_combinations.any?{|streak| streak.all?{|position| player1_move_positions.include? position}}
      self.update(:winner_identifier => self.player1_identifier)
    elsif Game.winner_combinations.any?{|streak| streak.all?{|position| player2_move_positions.include? position}}
      self.update(:winner_identifier => self.player2_identifier)
    end
    self.update(:complete => true) if self.game_over?
  end

  # Build the board for display in Slack
  # Build a board with a title, button tiles and game status
  def build_current_board
    {
      :text => "<@#{self.challenger_identifier}> challenged <@#{self.defendent_identifier}> for a game of Tic-Slack-Toe",
      :attachments => [self.build_tiles, self.build_game_status].flatten
    }
  end

  # build game status: complete or in progress based on complete flag
  def build_game_status
    if self.complete
      status_footer = "Game Complete"
      if self.winner_identifier.present?
        status_text = "<@#{self.winner_identifier}> won the game :clap:"
      else
        status_text = "That was a draw :whale:"
      end
    else
      status_footer = "Game in Progress"
      status_text = "<@#{self.next_player}> should play next"
    end
    {
      :text => status_text,
      :fallback => status_text,
      :color => "#FFFFFF",
      :footer => status_footer,
      :ts => self.created_at.to_i
    }
  end

  # build the board button tiles.
  # Mark the buttons appropriately if they were claimed by either players, or show default text
  def build_tiles
    player1_moves = self.moves_by_player[:player1].map{|move| [move.row, move.column]}
    player2_moves = self.moves_by_player[:player2].map{|move| [move.row, move.column]}
    # Each row in the board is a slack message attachment
    result = [*1..BOARD_SIZE].map do |row|
      {
        :callback_id => Game::ACTION_CALLBACK_KEY,
        :color => "#FFFFFF",
        :title => "",
        # Each column in a row is a button with an action (value: row,column)
        :actions => [*1..BOARD_SIZE].map do |column|
          button_text = Game::DEFAULT_BUTTON_TEXT
          if player1_moves.include? [row, column]
            button_text = Game::PLAYER1_BUTTON_TEXT
          elsif player2_moves.include? [row, column]
            button_text = Game::PLAYER2_BUTTON_TEXT
          end
          {
            :name => "#{self.id}",
            :text => button_text,
            :type => "button",
            :value => "#{row},#{column}"
          }
        end
      }
    end
    return result
  end

  private

  # Before any save, check if the game is complete
  def mark_complete_if_necessary
    if self.game_over?
      self.complete ||= true
    end
  end

  # Validate that the number of moves stays within the (board_size)^2
  def bound_moves_count
    unless self.moves_count.to_i.between? 0, MAX_MOVES
      self.errors.add(:moves_count, " Out of bounds")
    end
  end

  # Players cannot play themselves
  def different_players
    if self.player1_identifier == self.player2_identifier
      self.errors.add(:player1_identifier, " Players cannot be the same")
    end
  end

  # Winners (as denoted in winner_identifier) should have played the game (either playe1_identifier or player2_identifier)
  def winner_played
    if self.winner_identifier.present? and self.winner_identifier != self.player2_identifier and self.winner_identifier != self.player1_identifier
      self.errors.add(:winner_identifier, " Winner did not play?")
    end
  end
end
