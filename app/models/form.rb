class Form < ApplicationRecord
  include Rails.application.routes.url_helpers

  validates :name, presence: true, uniqueness: true
  validate :check_schema
  validate :check_layout

  def url
    form_url(id: self.id, identifier: Apartment::Tenant.current)
  end

  private
    def check_schema
      errors.add('schema', 'must be provided') if schema.nil?
    end

    def check_layout
      errors.add('layout', 'must be provided') if layout.nil?
    end
end
