module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    def render_create_success
      account = @resource.default_account || @resource
      Apartment::Tenant.switch(account.account_identifier) do
        render json: JSONAPI::Serializer.serialize(account), status: :ok
      end
    end
  end
end
