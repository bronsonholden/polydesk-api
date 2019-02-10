require 'test_helper'

class AccountUserPermissionTest < ActiveSupport::TestCase
  test 'add permission' do
    user = @account.users.create(name: 'Test User', email: 'test@polydesk.io', password: 'password')
    assert user
    account_user = AccountUser.where(account_id: @account.id, user_id: user.id).first
    assert_not account_user.nil?
    permission = account_user.permissions.create(code: 'document_create')
    assert permission.valid?
  end
end
