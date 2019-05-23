class UserResource < ApplicationResource
  attributes :name, :email, :password, :password_confirmation, :account_name, :identifier, :created_at, :updated_at
  has_many :users

  def fetchable_fields
    super - [:password, :password_confirmation]
  end
end
