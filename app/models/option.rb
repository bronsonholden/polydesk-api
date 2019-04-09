class Option < ApplicationRecord
  include Rails.application.routes.url_helpers

  enum name: [
    :document_storage_limit
  ]

  validates :name, presence: true
  validates :value, presence: true

  def url
    option_url(id: self.id, identifier: Apartment::Tenant.current)
  end
end
