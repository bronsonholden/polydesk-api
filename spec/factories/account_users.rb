FactoryBot.define do
  factory :account_user do
    user
    account { user.default_account }
  end

  factory :rspec_administrator, class: AccountUser do
    user
    account { Account.find_by_identifier!('rspec') }
    role { :administrator }
  end

  factory :rspec_guest, class: AccountUser do
    user
    account { Account.find_by_identifier!('rspec') }
  end
end
