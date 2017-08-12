class Game < ApplicationRecord

  BOARD_SIZE = 3
  MAX_MOVES = BOARD_SIZE**2
  DEFAULT_BUTTON_TEXT = ":white_large_square:"
  PLAYER1_BUTTON_TEXT = ":x:"
  PLAYER2_BUTTON_TEXT = ":o:"
  ACTION_CALLBACK_KEY = "tic-slack-toe-game"

  belongs_to :team
  has_many :moves, :dependent => :destroy

  scope :completed, -> { where(complete: true) }
  scope :active, -> { where(complete: false) }

  validates_presence_of :team_id, :channel_identifier
  validates_presence_of :player1_identifier, :player2_identifier, :challenger_identifier

  validates_uniqueness_of :channel_identifier, conditions: -> { where(complete: false) }

  validate :bound_moves_count, :different_players, :winner_played

  before_save :mark_complete_if_necessary

  def next_player
    # Whoever plays first is assigned player1. Players take alternate turns.
    (moves_by_player[:player1].size == moves_by_player[:player2].size) ? self.player1_identifier : self.player2_identifier
  end

  def moves_by_player
    player1_moves = self.moves.select{|x| x.player1_move}
    player2_moves = self.moves.select{|x| x.player2_move}
    return {:player1 => player1_moves, :player2 => player2_moves}
  end

  def defendent_identifier
    (self.challenger_identifier == self.player1_identifier) ? self.player2_identifier : self.player1_identifier
  end

  def build_current_board
    {
      :text => "<@#{self.challenger_identifier}> challenged <@#{self.defendent_identifier}> for a game of Tic-Slack-Toe",
      :attachments => [self.build_tiles, self.build_game_status].flatten
    }
  end

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

  def build_tiles
    player1_moves = self.moves_by_player[:player1].map{|move| [move.row, move.column]}
    player2_moves = self.moves_by_player[:player2].map{|move| [move.row, move.column]}
    result = [*1..BOARD_SIZE].map do |row|
      {
        :callback_id => Game::ACTION_CALLBACK_KEY,
        :color => "#FFFFFF",
        :title => "",
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

  def game_over?
    return (self.moves_count >= MAX_MOVES or winner_identifier.present?)
  end

  private

  def mark_complete_if_necessary
    if self.game_over?
      self.complete ||= true
    end
  end

  def bound_moves_count
    unless self.moves_count.to_i.between? 0, MAX_MOVES
      self.errors.add(:moves_count, " Out of bounds")
    end
  end

  def different_players
    if self.player1_identifier == self.player2_identifier
      self.errors.add(:player1_identifier, " Players cannot be the same")
    end
  end

  def winner_played
    if self.winner_identifier.present? and self.winner_identifier != self.player2_identifier and self.winner_identifier != self.player1_identifier
      self.errors.add(:winner_identifier, " Winner did not play?")
    end
  end
end
