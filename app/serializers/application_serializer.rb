class ApplicationSerializer
  include JSONAPI::Serializer

  def base_url
    opts = Rails.application.routes.default_url_options
    "#{opts[:protocol]}://#{opts[:host]}/#{Apartment::Tenant.current}"
  end

  # TODO: Implement
  def relationship_self_link(attribute_name)
    nil
  end

  def format_name(attribute_name)
    attribute_name.to_s.underscore
  end

  def unformat_name(attribute_name)
    attribute_name.to_s
  end
end
