class SetupWebState < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      INSERT INTO web_states (week_id)
        SELECT weeks.id FROM weeks JOIN seasons ON weeks.season_id = seasons.id
        WHERE seasons.year = 2014 AND week_number = 1;
    SQL
  end

  def down
    # noop
  end
end
