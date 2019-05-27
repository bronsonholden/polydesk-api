module Polydesk
  module Activation
    def link_account
      Apartment::Tenant.create(account_identifier)
      AccountUser.create!(account_id: id, user_id: id, role: :administrator)
    end
  end
end
