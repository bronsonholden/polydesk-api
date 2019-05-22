# Serializes an AccountUser, but under the guise of User. Relationships are
# established with a User's AccountUser record in an account (tenant), so
# we serialize the AccountUser and pull in any attributes/data from the
# corresponding User as needed.
class AccountUserResource < ApplicationResource
  attributes :name, :email, :role, :default_account, :confirmed_at, :confirmation_token, :created_at, :updated_at

  def initialize(*args)
    super
    @user = @model.user
  end

  def type
    :user
  end

  def name
    @user.name if @user
  end

  def email
    @user.email if @user
  end

  def confirmed_at
    @user.confirmed_at if @user
  end

  def confirmation_token
    if @model.role == :administrator
      @user.confirmation_token if @user
    else
      '*'
    end
  end

  # Only want to show default account identifier
  def default_account
    @user.default_account.identifier
  end

  # TODO: Fix this with rework of AccountUser/User API
  exclude_links [:self]
end
