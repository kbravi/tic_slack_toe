require 'rails_helper'

describe Slacker::RequestParser do

  let (:test_class) { Struct.new(:test_attribute) { include Slacker::RequestParser } }
  let (:test_instance) { test_class.new }

  let (:sample_json_string) {{:hello => "there", "key2" => "value2"}.to_json.to_s}
  let (:sample_hash) {{:hello => "there", "key2" => "value2"}}

  let (:sample_string) {"Hello there"}

  let (:sample_slack_user_identifier) {"<@U123456>"}
  let (:sample_slack_user_identifier_with_name) {"<@U123456|bob>"}

  describe "extract slack_user_identifier from text" do
    it "should process identifier with name" do
      expect(test_instance.extract_slack_user_identifier_from_text(sample_slack_user_identifier_with_name)).to eq("U123456")
    end

    it "should process slack_user_identifier without name" do
      expect(test_instance.extract_slack_user_identifier_from_text(sample_slack_user_identifier)).to eq("U123456")
    end

    it "should process some other text and do nothing" do
      expect(test_instance.extract_slack_user_identifier_from_text(sample_string)).to eq(sample_string)
    end
  end

  describe "parse json string to hash" do
    it "should convert json string to hash and symbolize keys" do
      value_hash = test_instance.parse_json_string_to_hash(sample_json_string)
      expect(value_hash.is_a? Hash).to eq(true)
      expect(value_hash.keys.first.is_a? Symbol).to eq(true)
    end

    it "should not do anything to a non string" do
      value_hash = test_instance.parse_json_string_to_hash(sample_hash)
      expect(value_hash.is_a? Hash).to eq(true)
      expect(value_hash.keys.first.is_a? Symbol).to eq(true)
      expect(value_hash.keys.second.is_a? Symbol).to eq(false)
    end
  end
end
