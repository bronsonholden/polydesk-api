class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :email

  # Only want to show default account identifier
  attribute :default_account do |user|
    user.default_account.identifier
  end

  has_many :accounts
end
