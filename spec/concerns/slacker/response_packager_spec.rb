require 'rails_helper'

describe Slacker::ResponsePackager do

  let (:test_class) { Struct.new(:test_attribute) { include Slacker::ResponsePackager } }
  let (:test_instance) { test_class.new }
  let (:sample_message_hash) {Hash.new(:hello => "there")}
  let (:sample_string) {"Hello there"}

  it "responds to success_response" do
    value_hash = test_instance.success_response(sample_message_hash)
    expect(value_hash[:status]).to eq(:ok)
    expect(value_hash[:json]).to eq(sample_message_hash)
  end

  it "responds to not_found_response" do
    value_hash = test_instance.not_found_response(sample_message_hash)
    expect(value_hash[:status]).to eq(:not_found)
    expect(value_hash[:json]).to eq(sample_message_hash)
  end

  it "responds to bad_request_response" do
    value_hash = test_instance.bad_request_response(sample_message_hash)
    expect(value_hash[:status]).to eq(:bad_request)
    expect(value_hash[:json]).to eq(sample_message_hash)
  end

  describe "responds to build_ephemeral" do
    it "with string input" do
      value_hash = test_instance.build_ephemeral(sample_string)
      expect(value_hash[:text]).to eq(sample_string)
      expect(value_hash[:response_type]).to eq("ephemeral")
    end

    it "with hash input" do
      value_hash = test_instance.build_ephemeral(sample_string)
      expect(value_hash).to include(sample_message_hash)
      expect(value_hash[:response_type]).to eq("ephemeral")
    end
  end

  describe "responds to build_in_channel" do
    it "with string input" do
      value_hash = test_instance.build_in_channel(sample_string)
      expect(value_hash[:text]).to eq(sample_string)
      expect(value_hash[:response_type]).to eq("in_channel")
    end

    it "with hash input" do
      value_hash = test_instance.build_in_channel(sample_string)
      expect(value_hash).to include(sample_message_hash)
      expect(value_hash[:response_type]).to eq("in_channel")
    end
  end

  describe "responds to build_replace_original" do
    it "with string input" do
      value_hash = test_instance.build_replace_original(sample_string)
      expect(value_hash[:text]).to eq(sample_string)
      expect(value_hash[:replace_original]).to eq(true)
    end

    it "with hash input" do
      value_hash = test_instance.build_replace_original(sample_string)
      expect(value_hash).to include(sample_message_hash)
      expect(value_hash[:replace_original]).to eq(true)
    end
  end

  describe "responds to build_not_replace_original" do
    it "with string input" do
      value_hash = test_instance.build_not_replace_original(sample_string)
      expect(value_hash[:text]).to eq(sample_string)
      expect(value_hash[:replace_original]).to eq(false)
    end

    it "with hash input" do
      value_hash = test_instance.build_not_replace_original(sample_string)
      expect(value_hash).to include(sample_message_hash)
      expect(value_hash[:replace_original]).to eq(false)
    end
  end
end
