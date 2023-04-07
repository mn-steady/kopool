class CreatePoolEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :pool_entries do |t|
      t.integer :user_id
      t.string :team_name
      t.boolean :paid

      t.timestamps
    end
  end
end
