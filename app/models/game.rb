class Game < ApplicationRecord
  BOARD_SIZE = 3
  MAX_MOVES = BOARD_SIZE**2

  belongs_to :team
  has_many :moves, :dependent => :destroy

  scope :completed, -> { where(complete: true) }
  scope :active, -> { where(complete: false) }

  validates_presence_of :team_id, :channel_identifier
  validates_presence_of :player1_identifier, :player2_identifier, :challenger_identifier

  validates_uniqueness_of :channel_identifier, conditions: -> { where(complete: false) }

  validate :bound_moves_count, :different_players, :winner_played

  before_save :mark_complete_if_necessary


  private

  def mark_complete_if_necessary
    if self.moves_count >= MAX_MOVES or winner_identifier.present?
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
