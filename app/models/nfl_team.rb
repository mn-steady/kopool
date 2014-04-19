class NflTeam < ActiveRecord::Base
	validates_presence_of :name, :conference, :division
end
