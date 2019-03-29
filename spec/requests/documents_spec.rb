require 'rails_helper'

RSpec.describe 'Documents', type: :request do
  describe 'GET /rspec/documents' do
    let!(:permission) { create :permission, code: 'document_index', account_user: AccountUser.last }
    it 'retrieves all documents' do
      get '/rspec/documents', headers: account_login('rspec', 'rspec@polydesk.io', 'password')
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /rspec/documents' do
    let!(:permission) { create :permission, code: 'document_create', account_user: AccountUser.last }
    it 'uploads a new document' do
      file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
      post '/rspec/documents', headers: account_login('rspec', 'rspec@polydesk.io', 'password'),
                               params: { content: file }
      expect(response).to have_http_status(201)
    end
  end
end
