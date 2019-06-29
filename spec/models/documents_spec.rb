require 'rails_helper'

describe Document do
  describe 'storage lifecycle' do
    context 'with background upload' do
      let!(:document) { create :document }
      it 'is correct' do
        expect(document.reload.content.data['storage']).to eq('store')
      end
    end

    context 'without background upload' do
      let!(:document) { create :document, set_skip_background_upload: false }
      it 'is correct' do
        expect(document.reload.content.data['storage']).to eq('cache')
      end
    end

    context 'during update' do
      let!(:document) { create :document }
      it 'is correct' do
        expect(document.reload.content.data['storage']).to eq('store')
        document.content = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt'))
        document.save!
        expect(document.reload.content.data['storage']).to eq('cache')
        document.content_attacher.promote
        document.save!
        expect(document.reload.content.data['storage']).to eq('store')
      end
    end
  end

  describe 'delete in folder' do
    let!(:document) { create :subdocument }
    it 'retains folder' do
      expect { document.destroy }.to change(Folder, :count).by(0)
    end
  end

  describe 'validations' do
    context 'with parent folder' do
      let!(:document) { create :subdocument, name: 'Subdocument' }

      it 'prevents duplicate name' do
        first_dup = document.folder.documents.create!(content: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt')), name: 'Subdocument')
        expect(first_dup.name).to eq('Subdocument (1)')
        second_dup = document.folder.documents.create!(content: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt')), name: 'Subdocument')
        expect(second_dup.name).to eq('Subdocument (2)')
      end
    end

    context 'without parent folder' do
      let!(:document) { create :document, name: 'Document' }

      it 'prevents duplicate name' do
        first_dup = Document.create!(content: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt')), name: 'Document')
        expect(first_dup.name).to eq('Document (1)')
        second_dup = Document.create!(content: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt')), name: 'Document')
        expect(second_dup.name).to eq('Document (2)')
      end
    end

    context 'when discarded' do
      let!(:discarded) { create :discarded_document, name: 'Discarded Document' }
      let!(:undiscarded) { create :document, name: 'Undiscarded Document' }
      # To undiscard later, to verify duplicate names not allowed on restore
      let!(:to_undiscard) { create :discarded_document, name: 'Undiscarded Document' }

      it 'allows duplicate name' do
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt'))
        expect { Document.create!(content: file, name: 'Discarded Document').discard! }.not_to raise_error
      end

      it 'name validation still applies' do
        expect { discarded.update!(name: '<Invalid') }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'undiscard enumerates name' do
        to_undiscard.undiscard!
        expect(to_undiscard.reload.name).to eq('Undiscarded Document (1)')
      end
    end
  end
end
