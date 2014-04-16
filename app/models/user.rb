class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :pool_entries
  belongs_to :favorite_team, class_name: "NflTeam"

  validates_presence_of :email, case_sensitive: false
  validates_presence_of :encrypted_password
end
