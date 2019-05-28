class AccountRealizer
  include JSONAPI::Realizer::Resource
  type :accounts, class_name: 'Account', adapter: :active_record
  has_many :users, class_name: 'UserRealizer'
  has :name
  has :identifier
  has :password
  has :password_confirmation
end
