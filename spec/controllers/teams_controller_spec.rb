require 'rails_helper'

RSpec.describe TeamsController, type: :controller do

  describe "GET #connect" do
    it "creates a team and connects" do
      valid_omniauth_mock_auth_slack
      get :connect, params: {provider: 'slack'}
      expect(response).to redirect_to("#{Team.last.slack_url}messages")
    end

    it "updates the team when team with same slack_identifier exists" do
      team = create(:team, :name => "123456")
      valid_omniauth_mock_auth_slack({:slack_identifier => team.slack_identifier, :team_name => "ABCDEF"})
      get :connect, params: {provider: 'slack'}
      expect(response).to redirect_to("#{Team.last.slack_url}messages")

      expect(Team.last.name).to_not eq("123456")
      expect(Team.last.name).to eq("ABCDEF")

      expect(Team.last.slack_identifier).to eq(team.slack_identifier)
    end
  end

  describe "GET connect_failure" do
    it "redirets to sorry" do
      get :connect_failure
      expect(response).to redirect_to('/sorry')
    end
  end
end
