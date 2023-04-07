class CreateNflTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :nfl_teams do |t|
      t.string :name
      t.string :conference
      t.string :division
      t.string :color
      t.string :abbreviation
      t.string :home_field
      t.string :website
      t.string :logo
      t.integer :wins
      t.integer :losses
      t.integer :ties

      t.timestamps
    end
  end
end
