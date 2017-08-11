require "rails_helper"

RSpec.describe Slacker::ActionsController, type: :routing do
  describe "routing" do
    it "routes to #receive" do
      expect(:post => "/slacker/actions/receive").to route_to(:controller => "slacker/actions", :action => "receive")
    end
  end
end
