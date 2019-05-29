FactoryBot.define do
  factory :user do
    first_name { 'Test' }
    last_name { 'User' }
    email { 'test@polydesk.io' }
    password { 'password' }
    association :default_account, factory: :account
    after(:create) do |user|
      user.confirm
    end
  end
end
