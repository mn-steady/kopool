class MainPageBubble < ApplicationRecord
  has_one_attached :image

  validates :image, presence: true

  def image_url
    begin
      image.variant(resize_to_fill: [360, 640]).processed.url
    rescue => e
      Rails.logger.error "Error generating thumbnail URL: #{e.message}"
      MainPageBubble.default_image_url
    end
  end

  def self.default_image_url
    ActionController::Base.helpers.asset_path('missing.png')
  end
end
