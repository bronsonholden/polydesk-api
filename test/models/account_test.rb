require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test 'setup account exists' do
    assert @account
  end

  test 'setup account config' do
    assert @account.name = 'Test Account'
    assert @account.identifier = 'test'
  end

  test 'invalid identifiers' do
    assert_not Account.create(name: 'Invalid 1', identifier: '2name').valid?
    assert_not Account.create(name: 'Invalid 2', identifier: 'a name').valid?
    assert_not Account.create(name: 'Invalid 3', identifier: 'a-name').valid?
    assert_not Account.create(name: 'Invalid 4', identifier: 'a/name').valid?
    assert_not Account.create(name: 'Invalid 5', identifier: 'a+name').valid?
    assert_not Account.create(name: 'Invalid 6', identifier: 'a!name').valid?
    assert_not Account.create(name: 'Invalid 7', identifier: 'a.name').valid?
    assert_not Account.create(name: 'Invalid 8', identifier: 'id').valid?
  end

  test 'valid identifiers' do
    assert Account.create(name: 'Valid 1', identifier: 'valid1').valid?
    assert Account.create(name: 'Valid 2', identifier: 'valid').valid?
    assert Account.create(name: 'Valid 3', identifier: 'val').valid?
  end
end
