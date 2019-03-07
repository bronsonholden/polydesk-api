require 'rails_helper'

describe Folder do
  describe 'delete with subfolder' do
    let(:folder) { create :subfolder }
    it 'deletes both folders' do
      folder
      expect { folder.parent.destroy }.to change(Folder, :count).by(-2)
    end
  end
end
