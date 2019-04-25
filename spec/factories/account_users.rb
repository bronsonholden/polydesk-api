FactoryBot.define do
  factory :account_user do
    user
    account { user.default_account }
  end
end
