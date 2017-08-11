require 'rails_helper'

RSpec.describe "Slacker::Commands", type: :request do

  describe "POST /slacker/commands/receive" do
    it "successfully responds to an authentic request" do
      post '/slacker/commands/receive',
            params: Slacker::MockCommandRequest.new({"team_id" => create(:team).slack_identifier}).verified
      expect(response).to have_http_status(200)
    end

    it "detects non authentic requests" do
      post '/slacker/commands/receive',
            params: Slacker::MockCommandRequest.new({"team_id" => create(:team).slack_identifier}).unverified
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["error"]).to eq("Verification Failed")
    end

    it "requires team_id to process the request" do
      post '/slacker/commands/receive', params: Slacker::MockCommandRequest.new.verified_invalid_team
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Incomplete request")
    end
  end
end
