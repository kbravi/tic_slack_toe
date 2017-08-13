class Move < ApplicationRecord

  # Columns
  # id: Primary Key
  # game_id: The game that this move is associated with
  # row: The row in the board that this move acts on
  # column: The column in the board that this move acts on
  # player1_move: Was it player1's move?
  # player2_move: Was it player2's move?

  # Every move is part of a game. Caches the moves count to game.moves_count
  belongs_to :game, :counter_cache => true

  validates_presence_of :game_id, :row, :column

  # Unique (row,column) for games
  validates_uniqueness_of :row, :scope => [:game_id, :column]
  validates_uniqueness_of :column, :scope => [:game_id, :row]

  validate :legal_row, :legal_column
  validate :exclusive_play


  private

  # Validates the (row) to exist in the board (limited by Game::BOARD_SIZE)
  def legal_row
    if self.row.blank? or !self.row.between?(1, Game::BOARD_SIZE)
      self.errors.add(:row, " position out of bound")
    end
  end

  # Validates the (column) to exist in the board (limited by Game::BOARD_SIZE)
  def legal_column
    if self.column.blank? or !self.column.between?(1, Game::BOARD_SIZE)
      self.errors.add(:column, " position out of bound")
    end
  end

  # Validates that a move is assigned to player1 or player2, not both
  def exclusive_play
    if(player2_move == player1_move)
      self.errors.add(:player1_move, " only one player can play a move")
    end
  end
end
