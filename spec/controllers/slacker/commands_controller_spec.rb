require 'rails_helper'

RSpec.describe Slacker::CommandsController, type: :controller do

  describe "POST #receive" do
    it "accepts commands and responds" do
      post :receive, params: Slacker::MockCommandRequest.new({"team_id" => create(:team).slack_identifier}).verified
      expect(response).to have_http_status(200)
    end
  end
end
