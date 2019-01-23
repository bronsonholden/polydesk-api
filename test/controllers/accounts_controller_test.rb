require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test 'Test account and user creation' do
    post '/accounts', params: { account_name: 'Controller Test',
                                account_identifier: 'controller',
                                user_name: 'Controller User',
                                user_email: 'controller@polydesk.io',
                                password: 'password',
                                password_confirmation: 'password' }
    assert_response :success
  end
end
