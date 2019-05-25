class AccountRealizer
  include JSONAPI::Realizer::Resource
  type :accounts, class_name: 'Account', adapter: :active_record
  # has_many :users, class_name: 'FolderRealizer'
  has :name
  has :identifier
end
