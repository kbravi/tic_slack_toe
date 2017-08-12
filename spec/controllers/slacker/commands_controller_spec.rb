require 'rails_helper'

RSpec.describe Slacker::CommandsController, type: :controller do

  describe "POST #receive" do
    it "accepts allowed commands and responds" do
      expect(controller).to_not receive(:unsupported_command_message)
      post :receive, params: Slacker::MockCommandRequest.new(
                  {
                    "team_id" => create(:team).slack_identifier,
                    :command => Slacker::CommandsController::ALLOWED_COMMANDS.first
                  }
                ).verified
      expect(response).to have_http_status(:ok)
    end

    it "doesn't allow other commands" do
      expect(controller).to receive(:unsupported_command_message)
      post :receive, params: Slacker::MockCommandRequest.new(
                  {
                    "team_id" => create(:team).slack_identifier,
                    :command => Slacker::CommandsController::ALLOWED_COMMANDS.first + "_not"
                  }
                ).verified
      expect(response).to have_http_status(:bad_request)
    end
  end
end
