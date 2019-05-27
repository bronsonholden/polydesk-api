FactoryBot.define do
  factory :account do
    name { 'Test user' }
    email { 'test@polydesk.io' }
    account_name { 'Test account' }
    account_identifier { 'test' }
    password { 'password' }
    after(:create) do |account, evaluator|
      account.confirm
      account.link_account
    end
  end
end
