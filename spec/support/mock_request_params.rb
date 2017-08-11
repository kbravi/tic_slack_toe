require 'faker'

module Slacker
  class MockCommandRequest
    attr_accessor :preset
    def initialize(preset=Hash.new)
      @preset = preset
    end

    def verified
       {
        "token"=>ENV['SLACK_VERIFICATION_TOKEN'],
        "team_id"=>Faker::Code.asin,
        "team_domain"=>Faker::Internet.domain_name,
        "channel_id"=>Faker::Code.asin,
        "channel_name"=>Faker::Name.first_name,
        "user_id"=>Faker::Code.asin,
        "user_name"=>Faker::Code.asin,
        "command"=>"/sample",
        "text"=>Faker::Code.asin,
        "response_url"=>Faker::Internet.url,
        "trigger_id"=>Faker::Code.asin
      }.deep_merge!(preset)
    end

    def unverified
      verified.deep_merge!(
        {
          "token" => ENV['SLACK_VERIFICATION_TOKEN'] + "INVALID"
        }
      ).deep_merge!(preset)
    end

    def verified_invalid_team
      verified.deep_merge!(
        {
          "team_id" => 0
        }
      ).deep_merge!(preset)
    end
  end

  class MockActionRequest
    attr_accessor :preset
    def initialize(preset=Hash.new)
      @preset = preset
    end

    def verified
      {
        "payload" => payload.deep_merge!(preset)
      }
    end

    def unverified
      {
        "payload" =>  payload.deep_merge!({
                        "token" => ENV['SLACK_VERIFICATION_TOKEN'] + "INVALID"
                      }).deep_merge!(preset)
      }
    end

    def verified_invalid_team
      {
        "payload" =>  payload.deep_merge!({
                        "team" => {"id" => 0}
                      }).deep_merge!(preset)
      }
    end

    def payload
      {
        "name" => Faker::Name.first_name,
        "value" => Faker::Name.first_name,
        "callback_id" => Faker::Name.first_name,
        "team" => {
          "id" => Faker::Code.asin,
          "domain" => Faker::Internet.domain_name
        },
        "channel" => {
          "id" => Faker::Code.asin,
          "name" => Faker::Name.first_name
        },
        "user" => {
          "id" => Faker::Code.asin,
          "name" => Faker::Name.first_name
        },
        "action_ts" => Faker::Code.asin,
        "message_ts" => Faker::Code.asin,
        "attachment_id" => Faker::Code.asin,
        "token" => ENV["SLACK_VERIFICATION_TOKEN"]
      }
    end
  end
end
