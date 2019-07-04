require 'rails_helper'

RSpec.describe 'Versions', type: :request do
  describe 'GET /rspec/documents/:id/versions' do
    let!(:document) { create :document }
    let!(:permission) { create :permission, code: :document_show, account_user: AccountUser.last }
    it 'retrieves all document versions' do
      document.name = 'New document name'
      document.save!
      get "/rspec/documents/#{document.id}/versions", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /rspec/documents/:id/versions/:version' do
    let!(:document) { create :versioned_document }
    let!(:permission) { create :permission, code: :document_show, account_user: AccountUser.last }
    it 'retrieves document version' do
      version = document.versions.last
      get "/rspec/documents/#{document.id}/versions/#{version.id}", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /rspec/folders/:id/versions' do
    let!(:folder) { create :folder }
    let!(:permission) { create :permission, code: :folder_show, account_user: AccountUser.last }
    it 'retrieves all folder versions' do
      folder.name = 'New folder name'
      folder.save!
      get "/rspec/folders/#{folder.id}/versions", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /rspec/folders/:id/versions/:version' do
    let!(:folder) { create :versioned_folder }
    let!(:permission) { create :permission, code: :folder_show, account_user: AccountUser.last }
    it 'retrieves folder version' do
      version = folder.versions.last
      get "/rspec/folders/#{folder.id}/versions/#{version.id}", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end
end
