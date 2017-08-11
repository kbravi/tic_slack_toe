require "rails_helper"

RSpec.describe TeamsController, type: :routing do
  describe "routing" do
    it "routes to #connect" do
      expect(:get => "/auth/slack/callback").to route_to(:controller => "teams", :action => "connect", :provider => "slack")
      expect(:get => "/auth/anything/callback").to route_to(:controller => "teams", :action => "connect", :provider => "anything")
    end

    it "routes to #connect_failure" do
      expect(:get => "/auth/failure").to route_to("teams#connect_failure")
    end
  end
end
