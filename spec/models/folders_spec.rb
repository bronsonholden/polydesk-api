require 'rails_helper'

describe Folder do
  describe 'delete with subfolder' do
    let!(:folder) { create :subfolder }
    it 'deletes both folders' do
      expect { folder.parent.destroy }.to change(Folder, :count).by(-2)
    end
  end

  describe 'delete with parent' do
    let!(:folder) { create :subfolder }
    it 'retains parent folder' do
      expect { folder.destroy }.to change(Folder, :count).by(-1)
    end
  end

  describe 'delete with document' do
    let!(:document) { create :subdocument }
    it 'deletes folder and document' do
      expect { document.folder.destroy }.to change(Document, :count).by(-1)
    end
  end

  describe 'validations' do
    context 'with parent folder' do
      let!(:folder) { create :subfolder, name: 'Subfolder' }
      it 'prevents duplicate name' do
        expect { folder.folders.create!(name: 'Subfolder') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'without parent folder' do
      let!(:folder) { create :folder, name: 'Folder' }
      it 'prevents duplicate name' do
        expect { Folder.create!(name: 'Document') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
