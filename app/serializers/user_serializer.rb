class UserSerializer < TenantSerializer
  attributes :first_name, :last_name, :email, :created_at, :updated_at
  has_many :accounts
end
