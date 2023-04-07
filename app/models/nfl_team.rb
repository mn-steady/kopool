class NflTeam < ApplicationRecord
  validates :name, :conference, :division, presence: true

  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "100x100>" }, s3_credentials: S3_CREDENTIALS, :default_url => "assets/missing.png"
  validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/

  def logo_url_small
    logo.url(:thumb)
  end

end
