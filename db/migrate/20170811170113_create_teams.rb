class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.text     "name"
      t.string   "slack_identifier"
      t.text     "slack_url"
      t.text     "email_domain"
      t.text     "slack_access_token"
      t.text     "slack_icon_url"
      t.string   "slack_authorized_user_identifier"
      t.timestamps
    end
    add_index :teams, :slack_identifier
  end
end
