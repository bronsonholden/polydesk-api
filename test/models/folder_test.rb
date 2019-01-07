require 'test_helper'

class FolderTest < ActiveSupport::TestCase
  test 'invalid without name' do
    folder = Folder.new
    assert_not folder.valid?
  end

  test 'disallows invalid name "."' do
    folder = Folder.new(name: '.')
    assert_not folder.valid?
  end

  test 'disallows invalid name: " "' do
    folder = Folder.new(name: ' ')
    assert_not folder.valid?
  end

  test 'disallows invalid name: " A"' do
    folder = Folder.new(name: ' A')
    assert_not folder.valid?
  end

  test 'disallows invalid name: "A "' do
    folder = Folder.new(name: 'A ')
    assert_not folder.valid?
  end

  test 'disallows invalid name: "A?"' do
    folder = Folder.new(name: 'A?')
    assert_not folder.valid?
  end

  test 'disallows invalid name: ""' do
    folder = Folder.new(name: '')
    assert_not folder.valid?
  end

  test 'disallows invalid name: "?:/\\~`"' do
    folder = Folder.new(name: '?:/\\~`')
    assert_not folder.valid?
  end
end
