class ApplicationSerializer
  include JSONAPI::Serializer

  def base_url
    opts = Rails.application.routes.default_url_options
    "#{opts[:protocol]}://#{opts[:host]}"
  end

  # TODO: Implement
  def relationship_self_link(attribute_name)
    nil
  end
end
