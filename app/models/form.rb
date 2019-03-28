class Form < ApplicationRecord
  include Rails.application.routes.url_helpers

  validates :name, presence: true, uniqueness: true
  validates :schema, presence: true
  validates :layout, presence: true

  def url
    form_url(id: self.id, identifier: Apartment::Tenant.current)
  end
end
