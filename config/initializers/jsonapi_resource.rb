JSONAPI.configure do |config|
  config.default_processor_klass = JSONAPI::Authorization::AuthorizingProcessor
  config.exception_class_whitelist = [ Pundit::NotAuthorizedError ]
end

module JSONAPI
  class LinkBuilder
    # This override is necessary because the LinkBuilder for jsonapi-resources
    # doesn't play nice with a parameterized route prefix. The tenant name is
    # the first route parameter, so we insert it.
    def call_url_helper(method, *args)
      routes.url_helpers.public_send(method, Apartment::Tenant.current, *args)
    rescue NoMethodError => e
      raise e
    end
  end
end
