require 'rails_helper'

describe Folder do
  describe 'delete with subfolder' do
    let!(:folder) { create :subfolder }
    it 'deletes both folders' do
      expect { folder.folder.destroy }.to change(Folder, :count).by(-2)
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
        expect { folder.folder.folders.create!(name: 'Subfolder') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'without parent folder' do
      let!(:folder) { create :folder, name: 'Folder' }
      it 'prevents duplicate name' do
        expect { Folder.create!(name: 'Folder') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when discarded' do
      let!(:discarded) { create :discarded_folder, name: 'Discarded Folder' }
      let!(:undiscarded) { create :folder, name: 'Undiscarded Folder' }
      # To undiscard later, to verify duplicate names not allowed on restore
      let!(:to_undiscard) { create :discarded_folder, name: 'Undiscarded Folder' }

      it 'allows duplicate name' do
        expect { Folder.create!(name: 'Discarded Folder').discard! }.not_to raise_error
      end

      it 'disallows restoring with duplicate name' do
        expect { to_undiscard.undiscard! }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'name validation still applies' do
        expect { discarded.update!(name: '<Invalid') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
