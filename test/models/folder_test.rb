require 'test_helper'

class FolderTest < ActiveSupport::TestCase
  test 'invalid without name' do
    assert_not Folder.new.save
  end

  test 'disallow invalid names' do
    assert_not Folder.new(name: '.').save
    assert_not Folder.new(name: ' ').save
    assert_not Folder.new(name: ' A').save
    assert_not Folder.new(name: 'A ').save
    assert_not Folder.new(name: 'A?').save
    assert_not Folder.new(name: '').save
    assert_not Folder.new(name: '?:/\\~`').save
  end

  test 'allow valid names' do
    assert Folder.new(name: 'A Folder. Name').save
  end
end
