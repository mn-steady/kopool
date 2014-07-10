class AddOpenForRegistrationToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :open_for_registration, :boolean, default: false
  end
end
