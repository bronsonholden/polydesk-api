# Serializes an AccountUser, but under the guise of User. Relationships are
# established with a User's AccountUser record in an account (tenant), so
# we serialize the AccountUser and pull in any attributes/data from the
# corresponding User as needed.
class AccountUserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :created_at, :updated_at

  set_type :user

  attribute :name do |account_user, params|
    user = account_user.user
    user.name if user
  end

  attributes :email do |account_user, params|
    user = account_user.user
    user.email if user
  end

  attribute :confirmed_at do |account_user, params|
    user = account_user.user
    (user.confirmed_at || '') if user
  end

  attribute :confirmation_token do |account_user, params|
    user = account_user.user
    if user && account_user.role == :administrator
      user.confirmation_token || ''
    else
      '*'
    end
  end

  attribute :role do |account_user, params|
    account_user.role
  end

  # Only want to show default account identifier
  attribute :default_account do |account_user, params|
    user = account_user.user
    user.default_account.identifier
  end
end
