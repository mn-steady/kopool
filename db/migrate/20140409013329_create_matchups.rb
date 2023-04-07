class CreateMatchups < ActiveRecord::Migration[7.0]
  def change
    create_table :matchups do |t|
      t.integer :week_id
      t.datetime :game_time
      t.integer :home_team_id
      t.integer :away_team_id
      t.boolean :completed
      t.boolean :tie
      t.integer :winning_team_id

      t.timestamps
    end
  end
end
