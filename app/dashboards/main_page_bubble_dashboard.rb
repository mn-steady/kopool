require "administrate/base_dashboard"

class MainPageBubbleDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    image: Field::ActiveStorage,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    image
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    image
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    image
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
