require 'rails_helper'

RSpec.describe Game, type: :model do

  it "has a valid factory" do
    expect(create(:game)).to be_valid
  end

  describe "Associations" do
    it {should belong_to(:team)}
    it {should have_many(:moves).dependent(:destroy)}
  end

  describe "Presence Validations" do
    subject { build(:game) }
    it {should validate_presence_of(:team_id)}
    it {should validate_presence_of(:channel_identifier)}
    it {should validate_presence_of(:player1_identifier)}
    it {should validate_presence_of(:player2_identifier)}
    it {should validate_presence_of(:challenger_identifier)}
  end

  describe "Unique Validations" do
    it "should validate uniqueness of channel_identifier within active games" do
      game1 = create(:game)
      game2 = build(:game, :channel_identifier => game1.channel_identifier + "_not")
      expect(game2).to be_valid
      game2.channel_identifier = game1.channel_identifier
      expect(game2).to_not be_valid
      game1.update(:complete => true)
      expect(game2).to be_valid
    end
  end

  describe "Custom Validations" do
    before(:each) do
      @game1 = build(:game)
    end
    it "should ensure moves_count stays within bounds" do
      expect(@game1).to be_valid
      @game1.moves_count = Game::MAX_MOVES + 1
      expect(@game1).to_not be_valid
    end

    it "should ensure players are different" do
      expect(@game1).to be_valid
      @game1.player2_identifier = @game1.player1_identifier
      expect(@game1).to_not be_valid
    end

    it "should ensure winner played" do
      expect(@game1).to be_valid
      @game1.winner_identifier = @game1.player1_identifier
      expect(@game1).to be_valid
      @game1.winner_identifier = @game1.player1_identifier + @game1.player2_identifier
      expect(@game1).to_not be_valid
    end
  end

  describe ".completed" do
    it "should return completed" do
      game1 = create(:game)
      expect(Game.completed).to eq([])
      game1.update(:complete => true)
      expect(Game.completed).to eq([game1])
    end
  end

  describe ".active" do
    it "should return currently active games" do
      game1 = create(:game)
      expect(Game.active).to eq([game1])
      game1.update(:complete => true)
      expect(Game.active).to eq([])
    end
  end

  describe "before_save" do
    before(:each) do
      @game1 = create(:game)
    end
    it "should mark games as complete when max moves is reached" do
      expect(@game1.complete).to eq(false)
      @game1.moves_count = Game::MAX_MOVES
      @game1.save
      expect(@game1.complete).to eq(true)
      @game1.moves_count = Game::MAX_MOVES - 1
      @game1.save
      expect(@game1.complete).to eq(true)
    end
    it "should mark games as complete when winner_identifier is present" do
      expect(@game1.complete).to eq(false)
      @game1.winner_identifier = @game1.player1_identifier
      @game1.save
      expect(@game1.complete).to eq(true)
      @game1.winner_identifier = nil
      @game1.save
      expect(@game1.complete).to eq(true)
    end
  end
end
