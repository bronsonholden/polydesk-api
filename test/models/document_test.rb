require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  test 'specified document name' do
    document = Document.create({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert document.valid?
    assert document.name == 'Document'
  end

  test 'default document name' do
    document = Document.create({ content: StringFileIO.new('Nothing') })
    assert document.valid?
    assert document.name == 'stringio.txt'
  end
end
