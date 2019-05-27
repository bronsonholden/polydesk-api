FactoryBot.define do
  factory :account_user do
    account { Account.first }
    association :user, factory: :account
    role { :user }
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
    role { :administrator }
  end

  factory :rspec_guest, parent: :account_user do
    role { :guest }
  end
end
