class CreatePicks < ActiveRecord::Migration
  def change
    create_table :picks do |t|
      t.integer :pool_entry_id
      t.integer :week_id
      t.integer :team_id
      t.boolean :locked_in

      t.timestamps
    end
  end
end
