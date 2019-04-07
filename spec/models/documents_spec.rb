require 'rails_helper'

describe Document do
  describe 'delete in folder' do
    let!(:document) { create :subdocument }
    it 'retains folder' do
      expect { document.destroy }.to change(Folder, :count).by(0)
    end
  end
end
