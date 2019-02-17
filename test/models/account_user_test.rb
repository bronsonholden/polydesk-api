require 'test_helper'

class AccountUserTest < ActiveSupport::TestCase
  test 'create user' do
    user = @account.users.create(name: 'Create User', email: 'create_user@polydesk.io', password: 'password', default_account: @account)
    assert user.valid?
    assert_not @account.users.empty?
    assert_not AccountUser.where(account_id: @account.id, user_id: user.id).empty?
  end

  test 'unique email' do
    first = @account.users.create(name: 'Unique User', email: 'unique_email@polydesk.io', password: 'password', default_account: @account)
    assert first.valid?
    second = @account.users.create(name: 'Unique User', email: 'unique_email@polydesk.io', password: 'password', default_account: @account)
    assert_not second.valid?
  end
end
