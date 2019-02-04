require 'test_helper'

class FolderDocumentTest < ActiveSupport::TestCase
  test 'File and unfile document' do
    # Create sample document and folder
    folder = Folder.new(name: 'Folder')
    document = Document.new({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert folder.save
    assert document.save
    # File the document
    document.folder = folder
    folder_document = FolderDocument.where(document_id: document.id, folder_id: folder.id).first
    assert folder_document.valid?
    assert_not Document.where(id: document.id).first.folder.nil?
    # Now destroy association (unfile document)
    folder_document.destroy
    assert FolderDocument.where(document_id: document.id, folder_id: folder.id).empty?
    assert Document.where(id: document.id).first.valid?
    assert Document.where(id: document.id).first.folder.nil?
  end

  test 'Disallow duplicate filings' do
    # Create sample document and folder
    folder = Folder.new(name: 'Folder')
    document = Document.new({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert folder.save
    assert document.save
    # File the document
    document.folder = folder
    # Ensure creating a second filing fails
    duplicate = FolderDocument.new({ folder: folder, document: document })
    assert_not duplicate.save
  end
end
