class AccountSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :identifier
  has_many :users
end
