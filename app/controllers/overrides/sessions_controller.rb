module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    def render_create_success
      account = @resource.default_account
      Apartment::Tenant.switch(account.identifier) do
        account_user = AccountUser.find_by!(account_id: account.id, user_id: @resource.id)
        render json: AccountUserSerializer.new(account_user).serialized_json, status: :ok
      end
    end
  end
end
