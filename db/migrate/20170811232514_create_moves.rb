class CreateMoves < ActiveRecord::Migration[5.1]
  def change
    create_table :moves do |t|
      t.integer :game_id
      t.integer :row
      t.integer :column
      t.boolean :player1_move, :default => false
      t.boolean :player2_move, :default => false
      t.timestamps
    end
    add_index :moves, :game_id
  end
end
