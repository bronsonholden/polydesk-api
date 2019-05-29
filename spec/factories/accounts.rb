FactoryBot.define do
  factory :account do
    name { 'Test Account' }
    identifier { 'test' }
    after(:create) do |account, evaluator|
      Apartment::Tenant.create(account.identifier)
    end
  end
end
