require 'test_helper'

class FormTest < ActiveSupport::TestCase
  test 'invalid without name' do
    assert_not Form.new.save
  end

  test 'allow valid names' do
    assert Folder.new(name: 'A test form').save
  end
end
