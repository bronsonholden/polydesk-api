FactoryBot.define do
  factory :user do
    name { 'Test user' }
    email { 'test@polydesk.io' }
    password { 'password' }
    association :default_account, factory: :account
    after(:create) do |user|
      user.create_tenant unless user.default_account.identifier == 'rspec'
      user.confirm
    end
  end

  factory :rspec_user, parent: :user do
    name { 'RSpec user' }
    email { 'rspec_user@polydesk.io' }
    default_account { Account.first }
  end
end
