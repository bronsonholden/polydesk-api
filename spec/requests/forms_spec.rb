require 'rails_helper'

RSpec.describe 'Forms', type: :request do
  describe 'GET /rspec/forms' do
    it 'retrieves all forms' do
      get forms_path(identifier: 'rspec'), headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end
end
