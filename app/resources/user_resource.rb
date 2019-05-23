class UserResource < ApplicationResource
  attributes :name, :email, :password, :password_confirmation, :account_name, :identifier, :created_at, :updated_at
  has_many :users

  # Canonical User resources should never be rendered, but we make them
  # non-fetchable and explicitly render null anyways.
  def fetchable_fields
    super - [:password, :password_confirmation]
  end

  def password
  end

  def password_confirmation
  end
end
