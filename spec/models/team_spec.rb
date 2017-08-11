require 'rails_helper'

RSpec.describe Team, type: :model do
  it "has a valid factory" do
    expect(create(:team)).to be_valid
  end

  describe "Presence Validations" do
    subject { FactoryGirl.build(:team) }
    it {should validate_presence_of(:slack_identifier)}
    it {should validate_presence_of(:slack_access_token)}
    it {should validate_presence_of(:slack_authorized_user_identifier)}
  end

  describe "Unique Validations" do
    subject { FactoryGirl.build(:team) }
    it {should validate_uniqueness_of(:slack_identifier)}
  end
end
