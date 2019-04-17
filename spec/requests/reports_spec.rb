require 'rails_helper'

RSpec.describe 'Reports', type: :request do
  describe 'GET /rspec/reports' do
    context 'with permission' do
      let!(:report) { create :report }
      let!(:permission) { create :permission, code: :report_index, account_user: AccountUser.last }
      it 'retrieves all reports' do
        get '/rspec/reports', headers: rspec_session
        expect(response).to have_http_status(200)
        expect(json).to be_array_of('report')
      end
    end

    context 'without permission' do
      let!(:report) { create :report }
      it 'returns authorization error' do
        get '/rspec/reports', headers: rspec_session
        expect(response).to have_http_status(403)
        expect(json).to have_errors
      end
    end
  end

  describe 'POST /rspec/reports' do
    context 'with permission' do
      let!(:permission) { create :permission, code: :report_create, account_user: AccountUser.last }
      it 'creates new report' do
        params = {
          name: 'RSpec Report'
        }
        post '/rspec/reports', headers: rspec_session, params: params.to_json
        expect(response).to have_http_status(201)
        expect(json).to be_a('report')
      end
    end

    context 'without permission' do
      it 'returns authorization error' do
        params = {
          name: 'RSpec Report'
        }
        post '/rspec/reports', headers: rspec_session, params: params.to_json
        expect(response).to have_http_status(403)
        expect(json).to have_errors
      end
    end
  end
end
