class Team < ApplicationRecord
  validates_presence_of :slack_identifier, :slack_access_token, :slack_authorized_user_identifier
  validates_uniqueness_of :slack_identifier
end