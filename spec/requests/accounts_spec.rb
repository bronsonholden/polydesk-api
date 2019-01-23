require 'rails_helper'

RSpec.describe "Accounts", type: :request do
  describe 'POST /accounts' do
    it 'creates test account' do
      post accounts_path, params: { account_name: 'Controller Test',
                                    account_identifier: 'controller',
                                    user_name: 'Controller User',
                                    user_email: 'controller@polydesk.io',
                                    password: 'password',
                                    password_confirmation: 'password' }
      expect(response).to have_http_status(201)
    end
  end
end
