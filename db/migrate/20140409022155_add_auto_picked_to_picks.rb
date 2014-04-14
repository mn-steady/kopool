class AddAutoPickedToPicks < ActiveRecord::Migration
  def change
    add_column :picks, :auto_picked, :boolean
  end
end
