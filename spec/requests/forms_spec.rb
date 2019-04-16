require 'rails_helper'

RSpec.describe 'Forms', type: :request do
  describe 'GET /rspec/forms' do
    context 'with permission' do
      let!(:form) { create :form }
      let!(:permission) { create :permission, code: :form_index, account_user: AccountUser.last }
      it 'retrieves all forms' do
        get '/rspec/forms', headers: rspec_session
        expect(response).to have_http_status(200)
        expect(json).to be_array_of('form')
      end
    end

    context 'without permission' do
      let!(:form) { create :form }
      it 'returns authorization error' do
        get '/rspec/forms', headers: rspec_session
        expect(response).to have_http_status(403)
        expect(json).to have_errors
      end
    end
  end

  describe 'POST /rspec/forms' do
    context 'with permission' do
      let!(:permission) { create :permission, code: :form_create, account_user: AccountUser.last }
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

    context 'without permission' do
      it 'returns authorization error' do
        params = {
          name: 'RSpec Form',
          schema: {},
          layout: {}
        }
        post '/rspec/forms', headers: rspec_session, params: params.to_json
        expect(response).to have_http_status(403)
        expect(json).to have_errors
      end
    end
  end
end
