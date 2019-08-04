require 'rails_helper'

describe Folder do
  let(:folder) { create :folder }
  let(:subfolder) { create :subfolder }
  let(:subdocument) { create :subdocument }

  describe 'deletion' do
    context 'with subfolder' do
      it 'deletes both folders' do
        subfolder
        expect { subfolder.folder.destroy }.to change(Folder, :count).by(-2)
      end
    end

    context 'with parent' do
      it 'retains parent folder' do
        subfolder
        expect { subfolder.destroy }.to change(Folder, :count).by(-1)
      end
    end

    context 'with document' do
      it 'deletes folder and document' do
        subdocument
        expect { subdocument.folder.destroy }.to change(Document, :count).by(-1)
      end
    end
  end

  describe 'validation' do
    context 'with parent folder' do
      it 'prevents duplicate name' do
        expect { subfolder.folder.folders.create!(name: subfolder.name) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'disallows being own parent' do
        expect { folder.update!(folder: folder) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'without parent folder' do
      it 'prevents duplicate name' do
        expect { Folder.create!(name: folder.name) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when discarded' do
      let(:discarded) { create :discarded_folder, name: 'Discarded Folder' }
      let(:undiscarded) { create :folder, name: 'Undiscarded Folder' }
      # To undiscard later, to verify duplicate names not allowed on restore
      let(:to_undiscard) { create :discarded_folder, name: 'Undiscarded Folder' }

      it 'allows duplicate name' do
        expect { Folder.create!(name: 'Discarded Folder').discard! }.not_to raise_error
      end

      it 'disallows restoring with duplicate name' do
        undiscarded
        expect { to_undiscard.undiscard! }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'name validation still applies' do
        expect { discarded.update!(name: '<Invalid') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
