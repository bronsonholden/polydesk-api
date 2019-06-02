class TenantSerializer < ApplicationSerializer
  def base_url
    "#{super}/#{Apartment::Tenant.current}"
  end
end
