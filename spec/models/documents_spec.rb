require 'rails_helper'

describe Document do
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
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt'))
        expect { document.folder.documents.create!(content: file, name: 'Subdocument') }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'requires content' do
        expect { Document.create!(name: 'No Content') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'without parent folder' do
      let!(:original) { create :document, name: 'Document' }

      it 'prevents duplicate name' do
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt'))
        expect { Document.create!(content: file, name: 'Document') }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'requires content' do
        expect { Document.create!(name: 'No Content') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
