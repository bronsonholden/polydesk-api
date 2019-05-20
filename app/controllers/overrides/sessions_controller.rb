module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    def render_create_success
      account = @resource.default_account
      Apartment::Tenant.switch(account.identifier) do
        account_user = AccountUser.find_by!(account_id: account.id, user_id: @resource.id)
        render json: JSONAPI::ResourceSerializer.new(AccountUserResource).serialize_to_hash(AccountUserResource.new(account_user, nil)), status: :ok
      end
    end
  end
end
