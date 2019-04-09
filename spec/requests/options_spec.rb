require 'rails_helper'

RSpec.describe 'Options', type: :request do
  describe 'GET /rspec/options' do
    let!(:option) { create :option, name: :document_storage_limit, value: '1000' }
    it 'retrieves all options' do
      get '/rspec/options', headers: rspec_session
      expect(response).to have_http_status(200)
      #expect(json).to be_array_of('option')
    end
  end

  describe 'POST /rspec/options' do
    it 'creates new option' do
      params = {
        name: 'document_storage_limit',
        value: '1000'
      }
      post '/rspec/options', headers: rspec_session, params: params.to_json
      expect(response).to have_http_status(201)
      #expect(json).to be_a('option')
    end
  end
end
