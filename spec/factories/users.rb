FactoryBot.define do
  factory :user do
    name { 'Test user' }
    email { 'test@polydesk.io' }
    association :default_account, factory: :account
  end
end
