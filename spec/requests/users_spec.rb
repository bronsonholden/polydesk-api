require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let!(:account) { Account.find_by(identifier: 'rspec') }
  let(:user) { create :user, email: 'rspec@notpolydesk.io' }
  let(:non_polydesk_user) { create :account_user, user: user, account: account }

  describe 'POST /users' do
    it 'creates new user' do
      post '/users', headers: base_headers,
                     params: {
                       data: {
                         type: 'users',
                         attributes: {
                           'first-name': 'New',
                           'last-name': 'User',
                           email: 'new_user@polydesk.io',
                           password: 'password',
                           'password-confirmation': 'password' } } }.to_json
      expect(response).to have_http_status(201)
    end
  end

  describe 'GET /users' do
    context 'as @polydesk.io user' do
      it 'lists all users' do
        get '/users', headers: rspec_session
        expect(response).to have_http_status(200)
      end
    end

    context 'as non @polydesk.io user' do
      it 'lists no users' do
        get '/users', headers: rspec_session(non_polydesk_user)
        body = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(body.dig('data').size).to eq(0)
      end
    end
  end

  describe 'GET /rspec/users' do
    context 'as non @polydesk.io user' do
      it 'lists no users' do
        get '/rspec/users', headers: rspec_session(non_polydesk_user)
        body = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(body.dig('data').size).to be > 0
      end
    end
  end
end
