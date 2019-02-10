require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  test 'require account user' do
    assert_not Permission.create.valid?
  end
end
