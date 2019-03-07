require 'rails_helper'

RSpec.describe 'Folders', type: :request do
  describe 'GET /rspec/folders' do
    it 'retrieves all folders' do
      get '/rspec/folders', headers: account_login('rspec', 'rspec@polydesk.io', 'password')
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /rspec/folders' do
    it 'creates new folder' do
      post '/rspec/folders', headers: account_login('rspec', 'rspec@polydesk.io', 'password'),
                             params: { name: 'RSpec Test' }.to_json

      expect(response).to have_http_status(201)
    end
  end

  describe 'GET /rspec/folders/1/folders' do
    let(:folder) { create :folder }
    it 'retrieves subfolders' do
      get "/rspec/folders/#{folder.id}/folders", headers: account_login('rspec', 'rspec@polydesk.io', 'password')
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE /rspec/folders/:folder' do
    let(:folder) { create :folder }
    it 'deletes folder' do
      delete "/rspec/folders/#{folder.id}", headers: account_login('rspec', 'rspec@polydesk.io', 'password')
      expect(response).to have_http_status(204)
    end
  end
end
