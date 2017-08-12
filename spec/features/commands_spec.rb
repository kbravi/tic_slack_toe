require 'rails_helper'

RSpec.describe Slacker::CommandsController, type: :controller do

  describe "Processing /ttt commands" do
    before(:each) do
      @team = create(:team)
    end

    it "accepts and responds" do
      post :receive, params: Slacker::MockCommandRequest.new(
                  {
                    "team_id" => @team.slack_identifier,
                    :command => '/ttt'
                  }
                ).verified
      expect(response).to have_http_status(:ok)
    end

    it "accepts any command text and responds" do
      expect(controller).to receive(:unidentified_command_message)
      post :receive, params: Slacker::MockCommandRequest.new(
                  {
                    "team_id" => @team.slack_identifier,
                    :command => '/ttt',
                    :text => "this is a bad command text"
                  }
                ).verified
      expect(response).to have_http_status(:ok)
    end

    it "should act on new" do
      expect_any_instance_of(Team).to receive(:new_game)
      post :receive, params: Slacker::MockCommandRequest.new(
                  {
                    "team_id" => @team.slack_identifier,
                    :command => '/ttt',
                    :text => "new"
                  }
                ).verified
      expect(response).to have_http_status(:ok)
    end

    it "should act on current" do
      expect_any_instance_of(Team).to receive(:current_game)
      post :receive, params: Slacker::MockCommandRequest.new(
                  {
                    "team_id" => @team.slack_identifier,
                    :command => '/ttt',
                    :text => "current"
                  }
                ).verified
      expect(response).to have_http_status(:ok)
    end

    it "should act on leaderboard" do
      expect_any_instance_of(Team).to receive(:leaderboard)
      post :receive, params: Slacker::MockCommandRequest.new(
                  {
                    "team_id" => @team.slack_identifier,
                    :command => '/ttt',
                    :text => "leaderboard"
                  }
                ).verified
      expect(response).to have_http_status(:ok)
    end

    it "should act on help" do
      expect(controller).to receive(:help_message)
      post :receive, params: Slacker::MockCommandRequest.new(
                  {
                    "team_id" => @team.slack_identifier,
                    :command => '/ttt',
                    :text => "help"
                  }
                ).verified
      expect(response).to have_http_status(:ok)
    end
  end
end
