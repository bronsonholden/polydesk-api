FactoryBot.define do
  factory :account_user do
    association :user, factory: :user
    account { User.find_by_identifier('rspec') }
    transient do
      set_permissions { [] }
    end
    after(:create) do |account_user, evaluator|
      evaluator.set_permissions.each do |code|
        account_user.permissions.create!(code: code)
      end
    end
  end

  factory :rspec_administrator, parent: :account_user do
    account { User.find_by_identifier!('rspec') }
    role { :administrator }
  end

  factory :rspec_guest, parent: :account_user do
    account { User.find_by_identifier!('rspec') }
  end
end
