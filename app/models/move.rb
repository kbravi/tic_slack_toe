class Move < ApplicationRecord
  belongs_to :game

  validates_presence_of :game_id, :row, :column

  validates_uniqueness_of :row, :scope => [:game_id, :column]
  validates_uniqueness_of :column, :scope => [:game_id, :row]

  validate :legal_row, :legal_column, :exclusive_play


  private

  def legal_row
    if self.row.blank? or !self.row.between?(1, Game::BOARD_SIZE)
      self.errors.add(:row, " position out of bound")
    end
  end

  def legal_column
    if self.column.blank? or !self.column.between?(1, Game::BOARD_SIZE)
      self.errors.add(:column, " position out of bound")
    end
  end

  def exclusive_play
    if(player2_move == player1_move)
      self.errors.add(:player1_move, " only one player can play a move")
    end
  end
end
