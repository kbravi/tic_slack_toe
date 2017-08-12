class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.integer :team_id
      t.string :channel_identifier
      t.string :player1_identifier
      t.string :player2_identifier
      t.string :challenger_identifier
      t.boolean :complete, :default => false
      t.string :winner_identifier
      t.integer :moves_count, :default => 0
      t.timestamps
    end
    add_index :games, :team_id
    add_index :games, :channel_identifier
    add_index :games, :winner_identifier
    add_index :games, [:team_id, :channel_identifier]
    add_index :games, [:team_id, :channel_identifier, :complete], :name => "index_team_channel_complete_on_game"
  end
end
