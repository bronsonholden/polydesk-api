FactoryBot.define do
  factory :account do
    name { 'Test Account' }
    identifier { 'test' }
    password { 'password' }
  end
end
