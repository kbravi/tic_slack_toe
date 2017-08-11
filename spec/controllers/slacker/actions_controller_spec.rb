require 'rails_helper'

RSpec.describe Slacker::ActionsController, type: :controller do
  describe "POST #receive" do
    it "accepts requests with allowed callback actions" do
      post :receive, params: Slacker::MockActionRequest.new(
                  {
                    "team" => {"id" => create(:team).slack_identifier},
                    "callback_id" => Slacker::ActionsController::ALLOWED_CALLBACKS.first
                  }
                ).verified
      expect(response).to have_http_status(:ok)
    end

    it "doesn't process other actions" do
      post :receive, params: Slacker::MockActionRequest.new(
                  {
                    "team" => {"id" => create(:team).slack_identifier},
                    "callback_id" => Slacker::ActionsController::ALLOWED_CALLBACKS.first + "_not"
                  }
                ).verified
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["error"]).to eq("Sorry. I don't understand the request")
    end
  end
end
