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

  describe ".winner_combinations" do
    it "should return all the winner combination positions" do
      expect(Game.winner_combinations.size).to eq(Game::BOARD_SIZE*2 + 2)
    end
  end

  describe "#next_player" do
    before(:each) do
      @game = create(:game)
    end
    it "should be a player of this game" do
      expect([@game.player1_identifier, @game.player2_identifier]).to include(@game.next_player)
    end

    it "should always be player 1 in a new game" do
      expect(@game.next_player).to eq(@game.player1_identifier)
      @game.player1_identifier, @game.player2_identifier = @game.player2_identifier, @game.player1_identifier
      expect(@game.next_player).to eq(@game.player1_identifier)
    end

    it "should select players alternatively" do
      expect(@game.next_player).to eq(@game.player1_identifier)
      create(:move, :game => @game, :player1_move => true, :row => 1, :column => 1)
      expect(@game.reload.next_player).to eq(@game.player2_identifier)
      create(:player2_move, :game => @game, :row => 1, :column => 2)
      expect(@game.reload.next_player).to eq(@game.player1_identifier)
    end
  end

  describe "#defendent_identifier" do
    it "should return the player who was challenged" do
      game = build(:game)
      expect(game.defendent_identifier).to eq(([game.player1_identifier, game.player2_identifier] - [game.challenger_identifier]).first)
    end
  end

  describe "#game_over?" do
    before(:each) do
      @game = build(:game)
    end

    it "should detect game completion when moves end" do
      expect(@game.game_over?).to eq(false)
      @game.moves_count = Game::MAX_MOVES
      expect(@game.game_over?).to eq(true)
    end

    it "should detect game completion when winner announced" do
      expect(@game.game_over?).to eq(false)
      @game.winner_identifier = @game.player1_identifier
      expect(@game.game_over?).to eq(true)
    end
  end

  describe "#moves_by_player" do
    it "should create a hash of moves by player" do
      game = create(:game)
      expect(game.moves_by_player[:player1]).to eq([])
      expect(game.moves_by_player[:player2]).to eq([])
      move1 = create(:move, :game => game, :player1_move => true, :row => 1, :column => 1)
      expect(game.reload.moves_by_player[:player1]).to eq([move1])
      expect(game.reload.moves_by_player[:player2]).to eq([])
      move2 = create(:player2_move, :game => game, :row => 1, :column => 2)
      expect(game.reload.moves_by_player[:player1]).to eq([move1])
      expect(game.reload.moves_by_player[:player2]).to eq([move2])
    end
  end

  describe "#evaluate_board_for_results" do
    it "should declare winners when winner combination is reached in a Tic Tac Toe game" do
      game = create(:game)
      expect(game.winner_identifier).to eq(nil)
      expect(game.complete).to eq(false)
      move1 = create(:move, :game => game, :player1_move => true, :row => 1, :column => 1)
      move2 = create(:player2_move, :game => game, :row => 2, :column => 1)
      move3 = create(:move, :game => game, :player1_move => true, :row => 1, :column => 2)
      move4 = create(:player2_move, :game => game, :row => 2, :column => 2)
      move5 = create(:move, :game => game, :player1_move => true, :row => 1, :column => 3)
      game.reload.evaluate_board_for_results
      expect(game.reload.winner_identifier).to eq(game.reload.player1_identifier)
      expect(game.reload.complete).to eq(true)
    end
  end

  describe "#build_current_board" do
    it "should build a hash for current board with correct text and attachments" do
      game = build(:game)
      expect(game).to receive(:build_tiles).at_least(:once)
      expect(game).to receive(:build_game_status).at_least(:once)
      expect(game.build_current_board.keys).to eq([:text, :attachments])
      expect(game.build_current_board[:text].is_a? String).to eq(true)
      expect(game.build_current_board[:attachments].size).to eq(2)
    end
  end

  describe "#build_game_status" do
    it "should build status" do
      game = build(:game)
      expect(game.build_game_status.keys).to eq([:text, :fallback, :color, :footer, :ts])
    end
  end

  describe "#build_tiles" do
    before(:each) do
      @game = create(:game)
    end

    it "should display all the tiles" do
      expect(@game.build_tiles.size).to eq(Game::BOARD_SIZE)
      expect(@game.build_tiles.first[:actions].size).to eq(Game::BOARD_SIZE)
    end

    it "should include correct callback_id" do
      expect(@game.build_tiles.map{|row| row[:callback_id]}.uniq).to eq([Game::ACTION_CALLBACK_KEY])
    end

    it "should display tiles with correct player markings" do
      expect(@game.build_tiles.size).to eq(Game::BOARD_SIZE)
      expect(@game.reload.build_tiles.map{|row| row[:actions].size}.uniq).to eq([Game::BOARD_SIZE])
      expect(@game.build_tiles.first[:actions].map{|action| action[:text]}.uniq).to eq([Game::DEFAULT_BUTTON_TEXT])
      move1 = create(:move, :game => @game, :player1_move => true, :row => 1, :column => 1)
      move2 = create(:player2_move, :game => @game, :row => 2, :column => 3)
      expect(@game.reload.build_tiles.size).to eq(Game::BOARD_SIZE)
      expect(@game.reload.build_tiles.map{|row| row[:actions].size}.uniq).to eq([Game::BOARD_SIZE])
      expect(@game.reload.build_tiles.first[:actions].map{|action| action[:text]}.uniq).to eq([Game::PLAYER1_BUTTON_TEXT, Game::DEFAULT_BUTTON_TEXT])
      expect(@game.reload.build_tiles.second[:actions].map{|action| action[:text]}.uniq).to eq([Game::DEFAULT_BUTTON_TEXT, Game::PLAYER2_BUTTON_TEXT])
    end
  end
end
