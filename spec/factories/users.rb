FactoryBot.define do
  factory :user do
    name { 'Test user' }
    email { 'test@polydesk.io' }
    password { 'password' }
    association :default_account, factory: :account
    after(:create) do |user|
      user.confirm
    end
  end
end
