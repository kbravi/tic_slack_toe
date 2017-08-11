require 'rails_helper'

RSpec.describe "Teams", type: :request do
  describe "GET /auth/slack/callback" do
    it "connects with valid omniauth.auth" do
      valid_omniauth_mock_auth_slack
      get '/auth/slack/callback'
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("#{Team.last.slack_url}messages")
    end

    it "fails to connect without valid omniauth.auth" do
      invalid_omniauth_mock_auth_slack
      get '/auth/slack/callback'
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("/auth/failure?message=invalid&strategy=slack")
    end
  end
end
