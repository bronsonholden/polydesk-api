require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  describe 'POST /accounts' do
    it 'creates new account with password' do
      post '/accounts', params: {
                          data: {
                            type: 'accounts',
                            attributes: {
                              account_identifier: 'rspec2',
                              account_name: 'RSpec 2',
                              name: 'RSpec User 2',
                              email: 'rspec2@polydesk.io',
                              password: 'password',
                              password_confirmation: 'password' } } }
      expect(response).to have_http_status(201)
      account = Account.find_by!(email: 'rspec2@polydesk.io')
      account_user = account.link_account
      expect(account.valid_password?('password')).to be true
      expect(account_user.role).to eq('administrator')
    end

    it 'creates new account without password' do
      post '/accounts', params: {
                          data: {
                            type: 'accounts',
                            attributes: {
                              account_identifier: 'rspec2',
                              account_name: 'RSpec 2',
                              name: 'RSpec User 2',
                              email: 'rspec2@polydesk.io' } } }
      expect(response).to have_http_status(201)
      expect(Account.last.has_password?).to be false
    end
  end

  describe 'GET /rspec/account' do
    it 'retrieves account information' do
      get '/rspec/account', headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'PATCH /rspec/account' do
    context 'with permission' do
      let!(:permission) { create :permission, code: :account_update, account_user: AccountUser.last }
      it 'updates account information' do
        account = Account.first
        patch '/rspec/account', headers: rspec_session,
                                params: {
                                  data: {
                                    id: account.id.to_s,
                                    type: 'accounts',
                                    attributes: {
                                      account_name: 'RSpec Renamed' } } }.to_json
        expect(response).to have_http_status(200)
        expect(account).to have_changed_attributes
        expect(account.reload.account_name).to eq('RSpec Renamed')
      end
    end

    context 'guest with permission' do
      let!(:guest) { create :rspec_guest, set_permissions: [:account_update] }
      it 'returns authorization error' do
        account = Account.first
        patch '/rspec/account', headers: rspec_session(guest),
                                params: {
                                  data: {
                                    id: account.id.to_s,
                                    type: 'accounts',
                                    attributes: {
                                      account_name: 'RSpec Renamed' } } }.to_json
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      it 'updates account information' do
        account = Account.first
        patch '/rspec/account', headers: rspec_session(admin),
                                params: {
                                  data: {
                                    id: account.id.to_s,
                                    type: 'accounts',
                                    attributes: {
                                      account_name: 'RSpec Renamed' } } }.to_json
        expect(response).to have_http_status(200)
        expect(account).to have_changed_attributes
        expect(account.reload.account_name).to eq('RSpec Renamed')
      end
    end

    context 'without permission' do
      it 'returns authorization error' do
        account = Account.last
        patch '/rspec/account', headers: rspec_session,
                                params: {
                                  data: {
                                    id: account.id.to_s,
                                    type: 'accounts',
                                    attributes: {
                                      account_name: 'RSpec Renamed' } } }.to_json
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
