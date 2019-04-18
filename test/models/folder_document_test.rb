require 'test_helper'

class FolderDocumentTest < ActiveSupport::TestCase
  test 'file and unfile document' do
    # Create sample document and folder
    folder = Folder.create(name: 'Folder')
    document = Document.create({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert folder.valid?
    assert document.valid?
    # File the document
    document.parent_folder = folder
    folder_document = FolderDocument.where(document_id: document.id, folder_id: folder.id).first
    assert folder_document.valid?
    assert_not Document.where(id: document.id).first.parent_folder.nil?
    # Now delete association (unfile document)
    folder_document.delete
    assert FolderDocument.where(document_id: document.id, folder_id: folder.id).empty?
    assert Document.where(id: document.id).first.valid?
    assert Document.where(id: document.id).first.parent_folder.nil?
  end

  test 'disallow duplicate filings' do
    # Create sample document and folder
    folder = Folder.create(name: 'Folder')
    document = Document.create({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert folder.valid?
    assert document.valid?
    # File the document
    document.parent_folder = folder
    # Ensure creating a second filing fails
    duplicate = FolderDocument.new({ folder: folder, document: document })
    assert_not duplicate.save
  end

  test 'delete folder and document' do
    folder = Folder.create(name: 'Folder')
    document = Document.create({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert folder.valid?
    assert document.valid?
    document.parent_folder = folder
    folder.destroy
    assert_not Folder.find_by_id(folder.id)
    assert_not Document.find_by_id(document.id)
  end

  test 'delete document retain folder' do
    folder = Folder.create(name: 'Folder')
    document = Document.create({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert folder.valid?
    assert document.valid?
    document.parent_folder = folder
    document.destroy
    assert Folder.find_by_id(folder.id)
    assert_not Document.find_by_id(document.id)
  end
end
