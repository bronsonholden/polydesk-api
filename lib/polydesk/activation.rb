module Polydesk
  module Activation
    def create_tenant(account=nil)
      account ||= Account.find(default_account.id)
      identifier = account.identifier

      Apartment::Tenant.create(identifier)
    end

    def link_account
      account = Account.find(default_account.id)
      identifier = account.identifier

      create_tenant

      Apartment::Tenant.switch(identifier) do
        AccountUser.create!(account_id: account.id, user_id: id, role: :administrator)
      end
    end
  end
end
