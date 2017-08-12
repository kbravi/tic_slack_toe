require 'rails_helper'

RSpec.describe Move, type: :model do
  it "has a valid factory" do
    expect(create(:move)).to be_valid
  end

  describe "Associations" do
    it {should belong_to(:game)}
  end

  describe "Presence Validations" do
    subject { build(:move) }
    it {should validate_presence_of(:game_id)}
    it {should validate_presence_of(:row)}
    it {should validate_presence_of(:column)}
  end

  describe "Uniqueness Validations" do
    subject { build(:move) }
    it {should validate_uniqueness_of(:row).scoped_to([:game_id, :column])}
    it {should validate_uniqueness_of(:column).scoped_to([:game_id, :row])}
  end

  describe "Custom Validations" do
    before(:each) do
      @move1 = build(:move)
    end
    it "should ensure if row is legal" do
      expect(@move1).to be_valid
      @move1.row = Game::BOARD_SIZE + 1
      expect(@move1).to_not be_valid
      @move1.row = Game::BOARD_SIZE - 1
      expect(@move1).to be_valid
    end
    it "should ensure if column is legal" do
      expect(@move1).to be_valid
      @move1.column = Game::BOARD_SIZE + 1
      expect(@move1).to_not be_valid
      @move1.column = Game::BOARD_SIZE - 1
      expect(@move1).to be_valid
    end
    it "should guarantee exclusive play" do
      expect(@move1).to be_valid
      @move1.player1_move = @move1.player2_move
      expect(@move1).to_not be_valid
      @move1.player1_move = !@move1.player2_move
      expect(@move1).to be_valid
    end
  end

end
