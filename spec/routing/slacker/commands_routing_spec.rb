require "rails_helper"

RSpec.describe Slacker::CommandsController, type: :routing do
  describe "routing" do
    it "routes to #receive" do
      expect(:post => "/slacker/commands/receive").to route_to(:controller => "slacker/commands", :action => "receive")
    end
  end
end
