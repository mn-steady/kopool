namespace :seasons do
	desc "This sets up the next season. Pass in a season name and first week start date (starting at 10 AM) with format YYYY-MM-DD HH:MM"
	task :setup_next_season, [:week_1_tuesday] => :environment do |t, args|
		@first_week_tuesday = DateTime.parse(args[:week_1_tuesday])
		@season = Season.create!(year: @first_week_tuesday.year, name: "#{@first_week_tuesday.year} KO Pool", entry_fee: 50, open_for_registration: false)
		(0..17).each do |week|
			week_start_tuesday = @first_week_tuesday + week.weeks
			week_deadline      = week_start_tuesday + 2.days
			week_end_date      = week_start_tuesday + 6.days
			Week.create!(
				season: @season, 
				start_date: week_start_tuesday, 
				deadline: week_deadline, 
				end_date: week_end_date, 
				week_number: week + 1,
				open_for_picks: false,
				active_for_scoring: false)
		end
	end
end