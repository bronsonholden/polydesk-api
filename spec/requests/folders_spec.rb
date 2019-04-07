require 'rails_helper'

RSpec.describe 'Folders', type: :request do
  describe 'GET /rspec/folders' do
    it 'retrieves all folders' do
      get '/rspec/folders', headers: rspec_session
      expect(response).to have_http_status(200)
      expect(json).to be_array_of('folder')
    end
  end

  describe 'POST /rspec/folders' do
    it 'creates new folder' do
      post '/rspec/folders', headers: rspec_session,
                             params: { name: 'RSpec Test' }.to_json

      expect(response).to have_http_status(201)
      expect(json).to be_a('folder')
    end
  end

  describe 'POST /rspec/folders/1/documents' do
    let!(:folder) { create :folder }
    let!(:permission) { create :permission, code: 'document_create', account_user: AccountUser.last }
    it 'uploads a document to a folder' do
      file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
      post "/rspec/folders/#{folder.id}/documents", headers: rspec_session,
                               params: { content: file }
      expect(response).to have_http_status(201)
      expect(json).to be_a('document')
    end
  end

  describe 'GET /rspec/folders/1/folders' do
    let!(:folder) { create :folder }
    it 'retrieves subfolders' do
      get "/rspec/folders/#{folder.id}/folders", headers: rspec_session
      expect(response).to have_http_status(200)
      expect(json).to be_array_of('folder')
    end
  end

  describe 'DELETE /rspec/folders/:folder' do
    let!(:folder) { create :folder }
    it 'deletes folder' do
      delete "/rspec/folders/#{folder.id}", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end
end
