class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Remember the user by default. Will only be signed out upon logout
  # Sets a 'remember_user_token' in the browser cookies
  def remember_me
    true
  end

  after_create :send_welcome_email

  has_many :pool_entries
  belongs_to :favorite_team, class_name: "NflTeam"

  validates_presence_of :email, case_sensitive: false
  validates_presence_of :encrypted_password

  private

    def send_welcome_email
      UserMailer.welcome_email(self).deliver
    end

end
