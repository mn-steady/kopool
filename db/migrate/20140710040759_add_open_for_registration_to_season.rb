class AddOpenForRegistrationToSeason < ActiveRecord::Migration[7.0]
  def change
    add_column :seasons, :open_for_registration, :boolean, default: false
  end
end
