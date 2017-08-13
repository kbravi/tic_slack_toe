require 'rails_helper'

RSpec.describe Team, type: :model do
  it "has a valid factory" do
    expect(create(:team)).to be_valid
  end

  describe "Associations" do
    it {should have_many(:games).dependent(:destroy)}
  end

  describe "Presence Validations" do
    subject { build(:team) }
    it {should validate_presence_of(:slack_identifier)}
    it {should validate_presence_of(:slack_access_token)}
    it {should validate_presence_of(:slack_authorized_user_identifier)}
  end

  describe "Unique Validations" do
    subject { build(:team) }
    it {should validate_uniqueness_of(:slack_identifier)}
  end

  describe "new_game" do
    before(:each) do
      @team = create(:team)
      @requested_game = build(:game, :team => @team)
    end

    it "should not create a new game if there is an active game in the channel" do
      active_game = create(:game, :team => @team, :channel_identifier => @requested_game.channel_identifier)
      expect{
        @team.reload.new_game(@requested_game.channel_identifier, @requested_game.player1_identifier, @requested_game.player2_identifier)
      }.to change{@team.reload.games.count}.by(0)
    end

    it "should require a defendent oppponent" do
      expect{
        @team.new_game(@requested_game.channel_identifier, @requested_game.player1_identifier, nil)
      }.to change{@team.reload.games.count}.by(0)
    end

    it "should check for a oppponent that is not the challenger" do
      expect{
        @team.new_game(@requested_game.channel_identifier, @requested_game.player1_identifier, @requested_game.player1_identifier)
      }.to change{@team.reload.games.count}.by(0)
    end

    it "should create a new game under valid conditions" do
      expect_any_instance_of(Game).to receive(:build_current_board)
      expect{
        @team.new_game(@requested_game.channel_identifier, @requested_game.player1_identifier, @requested_game.player2_identifier)
      }.to change{@team.reload.games.count}.by(1)
    end
  end

  describe "current_game" do
    before(:each) do
      @team = create(:team)
      @game = create(:game, :team => @team)
    end

    it "should build board when there is an active game" do
      expect_any_instance_of(Game).to receive(:build_current_board)
      @team.current_game(@game.channel_identifier)
    end

    it "should not build board when there is no active game" do
      expect_any_instance_of(Game).to_not receive(:build_current_board)
      @game.update(:complete => true)
      @team.reload.current_game(@game.channel_identifier)
    end

    it "should not build board when there is no game" do
      expect_any_instance_of(Game).to_not receive(:build_current_board)
      @game.destroy
      @team.reload.current_game(@game.channel_identifier)
    end
  end

  describe "process_move" do
    before(:each) do
      @team = create(:team)
    end

    it "should not create a move when there is no active game" do
      completed_game = create(:game, :team => @team, :complete => true)
      expect_any_instance_of(Game).to receive(:build_current_board)
      expect{
        @team.reload.process_move(completed_game.channel_identifier, completed_game.next_player, Slacker::MockMoveAction.new(completed_game.id, 1, 1).formatted)
      }.to change{Move.count}.by(0)
    end

    it "should not create a move when it is not the player's turn" do
      active_game = create(:game, :team => @team)
      not_next_player = ([active_game.player1_identifier, active_game.player2_identifier] - [active_game.next_player]).first
      expect_any_instance_of(Game).to receive(:build_current_board)
      expect{
        @team.reload.process_move(active_game.channel_identifier, not_next_player, Slacker::MockMoveAction.new(active_game.id, 1, 1).formatted)
      }.to change{Move.count}.by(0)
    end

    it "should create a new move when everything makes sense" do
      active_game = create(:game, :team => @team)
      expect_any_instance_of(Game).to receive(:evaluate_board_for_results)
      expect_any_instance_of(Game).to receive(:build_current_board)
      expect{
        @team.reload.process_move(active_game.channel_identifier, active_game.next_player, Slacker::MockMoveAction.new(active_game.id, 1, 1).formatted)
      }.to change{Move.count}.by(1)
    end
  end

  describe "leaderboard" do
    before(:each) do
      @team = create(:team)
      @channel_identifier = build(:game).channel_identifier
      @games = create_list(:game, 10, :team => @team)
      @in_channel_games = create_list(:game, 5, :team => @team, :complete => true, :channel_identifier => @channel_identifier)
    end

    it "should respond with a message" do
      leaderboard_response = @team.leaderboard(@channel_identifier)
      expect(leaderboard_response.keys).to eq([:text, :attachments, :response_type])
      expect(leaderboard_response[:text].is_a? String).to eq(true)
      expect(leaderboard_response[:attachments].is_a? Array).to eq(true)
    end

    it "should respond with a list of leaders within the channel" do
      leaderboard_response = @team.leaderboard(@channel_identifier)
      in_channel_players = @in_channel_games.map{|game| [game.player1_identifier, game.player2_identifier]}.flatten.uniq
      expect(leaderboard_response[:attachments].size).to eq(in_channel_players.size)
    end

    it "should respond with a list of leaders overall team" do
      leaderboard_response = @team.leaderboard
      all_players = (@games + @in_channel_games).map{|game| [game.player1_identifier, game.player2_identifier]}.flatten.uniq
      expect(leaderboard_response[:attachments].size).to eq(all_players.size)
    end
  end
end
