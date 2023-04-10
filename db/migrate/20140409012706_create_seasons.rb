class CreateSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :seasons do |t|
      t.integer :year
      t.string :name
      t.decimal :entry_fee

      t.timestamps
    end
  end
end
