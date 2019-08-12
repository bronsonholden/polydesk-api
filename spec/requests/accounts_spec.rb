require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  let(:attributes) {
    {
      identifier: 'rspec2',
      name: 'RSpec 2'
    }
  }

  let(:data) {
    {
      type: 'accounts',
      attributes: attributes
    }
  }

  let(:params) {
    {
      data: data
    }
  }

  let(:account) { Account.first }

  describe 'POST /accounts' do
    it 'creates new account with password' do
      post '/accounts', headers: rspec_session,
                        params: params.to_json
      expect(response).to have_http_status(201)
      expect(AccountUser.last.role).to eq('administrator')
    end

    it 'creates new account without password' do
      post '/accounts', headers: rspec_session,
                        params: params.to_json
      expect(response).to have_http_status(201)
    end
  end

  describe 'GET /accounts/1' do
    it 'retrieves account information' do
      get '/accounts/1', headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /accounts' do
    let!(:other_account) { create :account }

    it 'returns all accessible accounts' do
      get '/accounts', headers: rspec_session
      expect(response).to have_http_status(200)
      data = JSON.parse(response.body).fetch('data')
      ids = data.map { |account| account.fetch('id') }
      expect(ids).not_to include(other_account.id.to_s)
    end

    # TODO: test @polydesk.io user can index all accounts
  end

  describe 'PATCH /accounts/:id' do
    let(:data) {
      {
        id: account.id.to_s,
        type: 'accounts',
        attributes: attributes
      }
    }

    let(:attributes) {
      {
        name: 'RSpec Renamed'
      }
    }

    context 'with permission' do
      let!(:permission) { create :permission, code: :account_update, account_user: AccountUser.last }
      it 'updates account information' do
        patch "/accounts/#{account.id}", headers: rspec_session,
                                         params: params.to_json
        expect(response).to have_http_status(200)
        expect(account).to have_changed_attributes
        expect(account.reload.name).to eq('RSpec Renamed')
      end
    end

    context 'guest with permission' do
      let!(:guest) { create :rspec_guest, set_permissions: [:account_update] }
      it 'returns authorization error' do
        patch "/accounts/#{account.id}", headers: rspec_session(guest),
                                         params: params.to_json
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      it 'updates account information' do
        account = Account.first
        patch "/accounts/#{account.id}", headers: rspec_session(admin),
                                         params: params.to_json
        expect(response).to have_http_status(200)
        expect(account).to have_changed_attributes
        expect(account.reload.name).to eq('RSpec Renamed')
      end
    end

    context 'without permission' do
      it 'returns authorization error' do
        patch "/accounts/#{account.id}", headers: rspec_session,
                                         params: params.to_json
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
