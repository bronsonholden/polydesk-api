require 'rails_helper'

RSpec.describe 'Reports', type: :request do
  describe 'GET /rspec/reports' do
    context 'with permission' do
      let!(:report) { create :report }
      let!(:permission) { create :permission, code: :report_index, account_user: AccountUser.last }
      it 'retrieves all reports' do
        get '/rspec/reports', headers: rspec_session
        expect(response).to have_http_status(200)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      let!(:report) { create :report }
      it 'retrieves all reports' do
        get '/rspec/reports', headers: rspec_session(admin)
        expect(response).to have_http_status(200)
      end
    end

    context 'without permission' do
      let!(:report) { create :report }
      it 'returns authorization error' do
        get '/rspec/reports', headers: rspec_session
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'POST /rspec/reports' do
    context 'with permission' do
      let!(:permission) { create :permission, code: :report_create, account_user: AccountUser.last }
      it 'creates new report' do
        post '/rspec/reports', headers: rspec_session,
                               params: {
                                 data: {
                                   type: 'reports',
                                   attributes: {
                                     name: 'RSpec Report' } } }.to_json
        expect(response).to have_http_status(201)
      end
    end

    context 'guest with permission' do
      let!(:guest) { create :rspec_guest, set_permissions: [:report_create] }
      it 'returns authorization error' do
        post '/rspec/reports', headers: rspec_session(guest),
                               params: {
                                 data: {
                                   type: 'reports',
                                   attributes: {
                                     name: 'RSpec Report' } } }.to_json
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      it 'creates new report' do
        post '/rspec/reports', headers: rspec_session(admin),
                               params: {
                                 data: {
                                   type: 'reports',
                                   attributes: {
                                     name: 'RSpec Report' } } }.to_json
        expect(response).to have_http_status(201)
      end
    end

    context 'without permission' do
      it 'returns authorization error' do
        post '/rspec/reports', headers: rspec_session,
                               params: {
                                 data: {
                                   type: 'reports',
                                   attributes: {
                                     name: 'RSpec Report' } } }.to_json
        expect(response).to have_http_status(403)
      end
    end
  end

  # TODO: Test report updates
end
