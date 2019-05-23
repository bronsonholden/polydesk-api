module Polydesk
  module Activation
    def create_tenant
      Apartment::Tenant.create(identifier)
    end

    def link_account
      self.update(default_account_id: self.id)
      identifier = self.identifier
      create_tenant
      Apartment::Tenant.switch(identifier) do
        account_user = AccountUser.create!(account_id: self.id, user_id: self.id, role: :administrator)
        yield(account_user) if block_given?
      end
    end
  end
end
