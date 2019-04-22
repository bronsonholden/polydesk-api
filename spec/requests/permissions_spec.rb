require 'rails_helper'

RSpec.describe 'Permissions', type: :request do
  describe 'GET /rspec/user/:id/permissions' do
    let!(:permission) { create :permission, code: :document_show, account_user: AccountUser.last }
    it 'retrieves all document versions' do
      account_user = AccountUser.last
      get "/rspec/users/#{account_user.id}/permissions", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /rspec/user/:id/permissions' do
    it 'creates new permission' do
      account_user = AccountUser.last
      post "/rspec/users/#{account_user.id}/permissions", headers: rspec_session,
                                                         params: { code: :document_create }.to_json
      expect(response).to have_http_status(201)
    end

    context 'with existing permission' do
      let!(:permission) { create :permission, code: :document_create, account_user: AccountUser.last }
      it 'is idempotent' do
        account_user = AccountUser.last
        post "/rspec/users/#{account_user.id}/permissions", headers: rspec_session,
                                                           params: { code: :document_create }.to_json
        expect(response).to have_http_status(201)
      end
    end
  end

  describe 'DELETE /rspec/user/:id/permissions' do
    context 'with existing permission' do
      let!(:permission) { create :permission, code: :document_create, account_user: AccountUser.last }
      it 'removes permission' do
        account_user = AccountUser.last
        delete "/rspec/users/#{account_user.id}/permissions", headers: rspec_session,
                                                           params: { code: :document_create }.to_json
        expect(response).to have_http_status(204)
      end
    end

    context 'with no existing permission' do
      it 'is idempotent' do
        account_user = AccountUser.last
        delete "/rspec/users/#{account_user.id}/permissions", headers: rspec_session,
                                                           params: { code: :document_create }.to_json
        expect(response).to have_http_status(204)
      end
    end
  end
end
