class AccountSerializer < ApplicationSerializer
  attributes :name, :identifier, :created_at, :updated_at
  has_many :users
end
