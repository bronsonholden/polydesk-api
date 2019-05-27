class AccountRealizer
  include JSONAPI::Realizer::Resource
  type :accounts, class_name: 'Account', adapter: :active_record
  has_many :users, class_name: 'AccountRealizer'
  has :name
  has :email
  has :account_name
  has :account_identifier
  has :password
  has :password_confirmation
end
