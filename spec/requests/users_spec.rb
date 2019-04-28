require 'rails_helper'

RSpec.describe 'Versions', type: :request do
  describe 'GET /rspec/users' do
    it 'retrieves all users' do
      get "/rspec/users", headers: rspec_session
      expect(response).to have_http_status(200)
      expect(json).to be_array_of('user')
    end
  end
end
