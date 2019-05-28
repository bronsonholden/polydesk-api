require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'POST /users' do
    it 'creates new user' do
      post '/users', headers: base_headers,
                     params: {
                       data: {
                         type: 'users',
                         attributes: {
                           first_name: 'New',
                           last_name: 'User',
                           email: 'new_user@polydesk.io',
                           password: 'password',
                           password_confirmation: 'password' } } }.to_json
      expect(response).to have_http_status(201)
    end
  end
end
