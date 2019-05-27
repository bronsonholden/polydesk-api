class AccountSerializer < ApplicationSerializer
  attributes :account_name, :account_identifier, :name, :email, :created_at, :updated_at
  has_many :users
end
