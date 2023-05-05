class RemovePaperClipFieldsFromNflTeam < ActiveRecord::Migration[7.0]
  def change
    remove_column :nfl_teams, :logo_file_name, :string
    remove_column :nfl_teams, :logo_content_type, :string
    remove_column :nfl_teams, :logo_file_size, :integer
    remove_column :nfl_teams, :logo_updated_at, :datetime
  end
end
