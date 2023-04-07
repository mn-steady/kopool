class SeedPoolEntriesWithSeasonId < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE pool_entries
        SET season_id = seasons.id FROM seasons WHERE year = 2014 AND season_id IS NULL;
    SQL
  end

  def down
    # noop
  end
end
