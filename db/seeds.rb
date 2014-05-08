# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

NflTeam.find_or_create_by(name: "Denver Broncos", conference: "NFC", division: "West")
NflTeam.find_or_create_by(name: "Minnesota Vikins", conference: "NFC", division: "North")

season = Season.find_or_create_by(year: 2014, name: "Test Season", entry_fee: 75.00)
season2 = Season.find_or_create_by(year: 2015, name: "Next Season", entry_fee: 100.00)

Week.find_or_create_by(week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11), open: false, season_id: season.id)
Week.find_or_create_by(week_number: 2, start_date: DateTime.new(2014, 8, 12), deadline: DateTime.new(2014, 8, 15), end_date: DateTime.new(2014, 8, 18), open: true, season_id: season.id)
Week.find_or_create_by(week_number: 6, start_date: DateTime.new(2015, 10, 5), deadline: DateTime.new(2015, 10, 8), end_date: DateTime.new(2015, 10, 11), open: false, season_id: season2.id)
Week.find_or_create_by(week_number: 7, start_date: DateTime.new(2015, 10, 12), deadline: DateTime.new(2015, 10, 15), end_date: DateTime.new(2015, 10, 18), open: true, season_id: season2.id)

