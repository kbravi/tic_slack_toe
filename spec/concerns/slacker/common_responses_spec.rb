require 'rails_helper'

describe Slacker::CommonResponses do

  let (:test_class) { Struct.new(:test_attribute) { include Slacker::CommonResponses } }
  let (:test_instance) { test_class.new }

  it "responds to help_message" do
    expect(test_instance.help_message.is_a? String).to eq(true)
  end

  it "responds to verification_failed_message" do
    expect(test_instance.verification_failed_message.is_a? String).to eq(true)
  end

  it "responds to unidentified_command_message" do
    expect(test_instance.unidentified_command_message.is_a? String).to eq(true)
  end

  it "responds to incomplete_request_message" do
    expect(test_instance.incomplete_request_message.is_a? String).to eq(true)
  end

  it "responds to unsupported_command_message" do
    expect(test_instance.unsupported_command_message.is_a? String).to eq(true)
  end

  it "responds to unsupported_action_message" do
    expect(test_instance.unsupported_action_message.is_a? String).to eq(true)
  end
end
