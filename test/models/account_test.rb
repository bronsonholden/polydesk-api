require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test 'Setup account exist' do
    assert @account
  end

  test 'Setup account configured correctly' do
    assert @account.name = 'Test Account'
    assert @account.identifier = 'test'
  end
end
