class NflTeam < ApplicationRecord
  validates :name, :conference, :division, presence: true

  has_one_attached :logo
  validate :logo_is_image

  def logo_url_small
    return default_logo_small_url unless logo.attached?

    begin
      logo.variant(resize_to_fill: [100, 100]).processed.url
    rescue => e
      Rails.logger.error "Error generating thumbnail URL: #{e.message}"
      default_logo_small_url
    end
  end

  def default_logo_small_url
    ActionController::Base.helpers.asset_path('missing.png')
  end

  def logo_is_image
    if logo.attached? && !logo.image?
      errors.add(:logo, 'must be an image')
    end
  end
end
