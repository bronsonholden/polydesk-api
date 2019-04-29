module Polydesk
  module Activation
    def link_account
      account = Account.find(default_account.id)
      identifier = account.identifier

      Apartment::Tenant.create(identifier)
      Apartment::Tenant.switch(identifier) do
        AccountUser.create!(account_id: account.id, user_id: id, role: :administrator)
      end
    end
  end
end
