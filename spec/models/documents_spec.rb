require 'rails_helper'

describe Folder do
  describe 'delete in folder' do
    let(:document) { create :subdocument }
    it 'retains folder' do
      document
      expect { document.destroy }.to change(Folder, :count).by(0)
    end
  end
end
