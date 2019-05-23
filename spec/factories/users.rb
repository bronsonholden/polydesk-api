FactoryBot.define do
  factory :user do
    name { 'Test user' }
    email { 'test@polydesk.io' }
    password { 'password' }
    account_name { 'Test user account' }
    identifier { 'test' }
    after(:create) do |user|
      user.link_account
      user.confirm
    end
  end
end
