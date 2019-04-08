class Report < ApplicationRecord
  include Rails.application.routes.url_helpers

  validates :name, presence: true

  def url
    report_url(id: self.id, identifier: Apartment::Tenant.current)
  end
end
