class UserRealizer
  include JSONAPI::Realizer::Resource
  type :users, class_name: 'User', adapter: :active_record
  has_many :accounts, class_name: 'AccountRealizer'
  has :first_name
  has :last_name
  has :email
  has :password
  has :password_confirmation
end
