require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :team do
    name {Faker::Company.name}
    slack_url {Faker::Internet.url}
    slack_identifier {Faker::Code.asin}
    email_domain {Faker::Internet.domain_name}
    slack_access_token {Faker::Crypto.md5}
    slack_icon_url {Faker::Placeholdit.image}
    slack_authorized_user_identifier {Faker::Name.first_name}
  end
end
