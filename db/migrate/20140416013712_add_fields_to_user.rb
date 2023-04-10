class AddFieldsToUser < ActiveRecord::Migration[7.0]
  def change
  	add_column :users, :favorite_team_id, :integer
  	add_column :users, :phone, :string
  	add_column :users, :paid_at, :datetime
  	add_column :users, :comments, :text
  	add_column :users, :cell, :string
  end
end
