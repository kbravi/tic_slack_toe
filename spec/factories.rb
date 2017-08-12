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

  factory :game do
    team
    channel_identifier {Faker::Code.asin}
    player1_identifier {Faker::Code.asin}
    player2_identifier {Faker::Code.asin}
    challenger_identifier { player1_identifier }
  end

  factory :move do
    game
    row {[*1..Game::BOARD_SIZE].sample}
    column {[*1..Game::BOARD_SIZE].sample}
    player1_move true
    player2_move false

    factory :player1_move do
      player1_move true
      player2_move false
    end

    factory :player2_move do
      player2_move true
      player1_move false
    end
  end
end
