require "administrate/base_dashboard"

class NflTeamDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    abbreviation: Field::String,
    color: Field::String,
    conference: Field::String,
    division: Field::String,
    home_field: Field::String,
    logo_content_type: Field::String,
    logo_file_name: Field::String,
    logo_file_size: Field::Number,
    logo_updated_at: Field::DateTime,
    losses: Field::Number,
    name: Field::String,
    ties: Field::Number,
    website: Field::String,
    wins: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    abbreviation
    color
    conference
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    abbreviation
    color
    conference
    division
    home_field
    logo_content_type
    logo_file_name
    logo_file_size
    logo_updated_at
    losses
    name
    ties
    website
    wins
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    abbreviation
    color
    conference
    division
    home_field
    logo_content_type
    logo_file_name
    logo_file_size
    logo_updated_at
    losses
    name
    ties
    website
    wins
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how nfl teams are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(nfl_team)
    nfl_team.name
  end
end
