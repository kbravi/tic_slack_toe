require 'rails_helper'

RSpec.describe Slacker::ActionsController, type: :controller do

  describe "Game Play Action with callback tic-slack-toe-game" do
    before(:each) do
      @team = create(:team)
      @callback_id = "tic-slack-toe-game"
    end

    it "accept and respond" do
      expect_any_instance_of(Team).to receive(:process_move)
      post :receive, params: Slacker::MockActionRequest.new(
                  {
                    "team" => {"id" => @team.slack_identifier},
                    "callback_id" => @callback_id
                  }
                ).verified
      expect(response).to have_http_status(:ok)
    end
  end
end
