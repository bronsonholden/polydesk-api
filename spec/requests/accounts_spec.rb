require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  describe 'POST /accounts' do
    it 'creates new account with password' do
      post '/accounts', params: { account_identifier: 'rspec2',
                                  account_name: 'RSpec 2',
                                  user_name: 'RSpec User 2',
                                  user_email: 'rspec2@polydesk.io',
                                  password: 'password',
                                  password_confirmation: 'password' }
      expect(response).to have_http_status(201)
      expect(json).to be_an('account')
      expect(User.last.valid_password?('password')).to be true
    end

    it 'creates new account without password' do
      post '/accounts', params: { account_identifier: 'rspec3',
                                  account_name: 'RSpec 3',
                                  user_name: 'RSpec User 3',
                                  user_email: 'rspec3@polydesk.io' }
      expect(response).to have_http_status(201)
      expect(json).to be_an('account')
      expect(User.last.has_password?).to be false
    end
  end

  describe 'GET /rspec/account' do
    it 'retrieves account information' do
      get '/rspec/account', headers: rspec_session
      expect(response).to have_http_status(200)
      expect(json).to be_an('account')
    end
  end

  # TODO: Create Account factory, verify access is forbidden
  # describe 'GET /acme/account' do
  #   it 'blocks restricted account information retrieval' do
  #     get '/acme/account', headers: rspec_session
  #     expect(response).to have_http_status(404)
  #     expect(json).to have_errors
  #   end
  # end

  describe 'GET /accounts' do
    it 'retrieves all available accounts' do
      get '/accounts', headers: rspec_session
      expect(response).to have_http_status(200)
      expect(json).to be_array_of('account')
    end
  end

  describe 'GET /rspec/users' do
    it 'retrieves all account users' do
      get '/rspec/users', headers: rspec_session
      expect(response).to have_http_status(200)
      expect(json).to be_array_of('user')
    end
  end
end
