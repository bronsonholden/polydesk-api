require 'test_helper'

class FolderDocumentTest < ActiveSupport::TestCase
  test 'file and unfile document' do
    # Create sample document and folder
    folder = Folder.create(name: 'Folder')
    document = Document.create({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert folder.valid?
    assert document.valid?
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

  test 'disallow duplicate filings' do
    # Create sample document and folder
    folder = Folder.create(name: 'Folder')
    document = Document.create({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert folder.valid?
    assert document.valid?
    # File the document
    document.folder = folder
    # Ensure creating a second filing fails
    duplicate = FolderDocument.new({ folder: folder, document: document })
    assert_not duplicate.save
  end

  test 'delete folder retain document' do
    folder = Folder.create(name: 'Folder')
    document = Document.create({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert folder.valid?
    assert document.valid?
    document.folder = folder
    folder.destroy
    assert_not Folder.find_by_id(folder.id)
    assert Document.find_by_id(document.id).folder.nil?
    assert Document.find_by_id(document.id)
  end

  test 'delete document retain folder' do
    folder = Folder.create(name: 'Folder')
    document = Document.create({ name: 'Document', content: StringFileIO.new('Nothing') })
    assert folder.valid?
    assert document.valid?
    document.folder = folder
    document.destroy
    assert Folder.find_by_id(folder.id)
    assert_not Document.find_by_id(document.id)
  end
end
