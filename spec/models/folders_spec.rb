require 'rails_helper'

describe Folder do
  describe 'delete with subfolder' do
    let(:folder) { create :subfolder }
    it 'deletes both folders' do
      folder
      expect { folder.parent.destroy }.to change(Folder, :count).by(-2)
    end
  end

  describe 'delete with parent' do
    let(:folder) { create :subfolder }
    it 'retains parent folder' do
      folder
      expect { folder.destroy }.to change(Folder, :count).by(-1)
    end
  end

  describe 'delete with document' do
    let(:document) { create :subdocument }
    it 'deletes folder and document' do
      document
      expect { document.folder.destroy }.to change(Document, :count).by(-1)
    end
  end
end
