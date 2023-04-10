class AddAutoPickedToPicks < ActiveRecord::Migration[7.0]
  def change
    add_column :picks, :auto_picked, :boolean
  end
end
