require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  describe 'POST /accounts' do
    it 'creates new account with password' do
      post '/accounts', headers: rspec_session,
                        params: {
                          data: {
                            type: 'accounts',
                            attributes: {
                              identifier: 'rspec2',
                              name: 'RSpec 2' } } }.to_json
      expect(response).to have_http_status(201)
    end

    it 'creates new account without password' do
      post '/accounts', headers: rspec_session,
                        params: {
                          data: {
                            type: 'accounts',
                            attributes: {
                              identifier: 'rspec2',
                              name: 'RSpec 2' } } }.to_json
      expect(response).to have_http_status(201)
    end
  end

  describe 'GET /accounts/1' do
    it 'retrieves account information' do
      get '/accounts/1', headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'PATCH /accounts/:id' do
    context 'with permission' do
      let!(:permission) { create :permission, code: :account_update, account_user: AccountUser.last }
      it 'updates account information' do
        account = Account.first
        patch "/accounts/#{account.id}", headers: rspec_session,
                                         params: {
                                           data: {
                                             id: account.id.to_s,
                                             type: 'accounts',
                                               attributes: {
                                                 name: 'RSpec Renamed' } } }.to_json
        expect(response).to have_http_status(200)
        expect(account).to have_changed_attributes
        expect(account.reload.name).to eq('RSpec Renamed')
      end
    end

    context 'guest with permission' do
      let!(:guest) { create :rspec_guest, set_permissions: [:account_update] }
      it 'returns authorization error' do
        account = Account.first
        patch "/accounts/#{account.id}", headers: rspec_session(guest),
                                         params: {
                                           data: {
                                             id: account.id.to_s,
                                             type: 'accounts',
                                               attributes: {
                                                 name: 'RSpec Renamed' } } }.to_json
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      it 'updates account information' do
        account = Account.first
        patch "/accounts/#{account.id}", headers: rspec_session(admin),
                                         params: {
                                           data: {
                                             id: account.id.to_s,
                                             type: 'accounts',
                                               attributes: {
                                                 name: 'RSpec Renamed' } } }.to_json
        expect(response).to have_http_status(200)
        expect(account).to have_changed_attributes
        expect(account.reload.name).to eq('RSpec Renamed')
      end
    end

    context 'without permission' do
      it 'returns authorization error' do
        account = Account.last
        patch "/accounts/#{account.id}", headers: rspec_session,
                                         params: {
                                           data: {
                                             id: account.id.to_s,
                                             type: 'accounts',
                                               attributes: {
                                                 name: 'RSpec Renamed' } } }.to_json
        expect(response).to have_http_status(403)
      end
    end
  end

  # TODO: Create Account factory, verify access is forbidden
  # describe 'GET /acme/account' do
  #   it 'blocks restricted account information retrieval' do
  #     get '/acme/account', headers: rspec_session
  #     expect(response).to have_http_status(404)
  #   end
  # end
end
