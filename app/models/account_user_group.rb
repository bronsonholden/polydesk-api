class AccountUserGroup < ApplicationRecord
  belongs_to :account_user, class_name: 'AccountUser', foreign_key: 'account_user_id'
  belongs_to :group
end
