class BubbleUpload < ApplicationRecord
  enum :tier, %i[0_3 4_19 20_36 37_70 71_99 100]

  has_one_attached :image

  validates :tier, :image, presence: true

  def image_url
    begin
      image.variant(resize_to_fill: [100, 100]).processed.url
    rescue => e
      Rails.logger.error "Error generating thumbnail URL: #{e.message}"
      BubbleUpload.default_image_url
    end
  end

  def self.default_image_url
    ActionController::Base.helpers.asset_path('missing.png')
  end
end
