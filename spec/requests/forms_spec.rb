require 'rails_helper'

RSpec.describe 'Forms', type: :request do
  describe 'GET /rspec/forms' do
    let!(:form) { create :form }
    it 'retrieves all forms' do
      get '/rspec/forms', headers: rspec_session
      expect(response).to have_http_status(200)
      expect(json).to be_array_of('form')
    end
  end

  describe 'POST /rspec/forms' do
    it 'creates new form' do
      params = {
        name: 'RSpec Form',
        schema: {},
        layout: {}
      }
      post '/rspec/forms', headers: rspec_session, params: params.to_json
      expect(response).to have_http_status(201)
      expect(json).to be_a('form')
    end
  end
end
