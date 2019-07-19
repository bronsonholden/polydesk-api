require 'rails_helper'

RSpec.describe 'Documents', type: :request do
  let(:admin) { create :rspec_administrator }
  let(:document) { create :document }

  describe 'GET /rspec/documents' do
    context 'with permission' do
      let!(:permission) { create :permission, code: 'document_index', account_user: AccountUser.last }
      it 'retrieves all documents' do
        get '/rspec/documents', headers: rspec_session
        expect(response).to have_http_status(200)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      it 'retrieves all documents' do
        get '/rspec/documents', headers: rspec_session(admin)
        expect(response).to have_http_status(200)
      end
    end

    context 'without permission' do
      it 'returns authorization error' do
        get '/rspec/documents', headers: rspec_session
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'GET /rspec/documents/1' do
    let!(:permission) { create :permission, code: 'document_show', account_user: AccountUser.last }
    it 'retrieves document' do
      get "/rspec/documents/#{document.id}", headers: rspec_session
      expect(response).to have_http_status(200)
    end

    context 'admin without permission' do
      it 'retrieves document' do
        get "/rspec/documents/#{document.id}", headers: rspec_session(admin)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'DELETE /rspec/documents/1' do
    let!(:permission) { create :permission, code: 'document_destroy', account_user: AccountUser.last }
    it 'deletes document' do
      delete "/rspec/documents/#{document.id}", headers: rspec_session
      expect(response).to have_http_status(204)
      Apartment::Tenant.switch('rspec') do
        document.reload
        expect(document.discarded_at).not_to be_nil
      end
    end

    context 'guest with permission' do
      let!(:guest) { create :rspec_guest, set_permissions: [:document_destroy] }
      it 'returns authorization error' do
        delete "/rspec/documents/#{document.id}", headers: rspec_session(guest)
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      it 'deletes document' do
        delete "/rspec/documents/#{document.id}", headers: rspec_session(admin)
        expect(response).to have_http_status(204)
        Apartment::Tenant.switch('rspec') do
          document.reload
          expect(document.discarded_at).not_to be_nil
        end
      end
    end
  end

  describe 'GET /rspec/documents/1/download' do
    let(:document) { create :versioned_document }

    context 'with permission' do
      let!(:permission) { create :permission, code: 'document_show', account_user: AccountUser.last }
      it 'downloads current version' do
        get "/rspec/documents/#{document.id}/download", headers: rspec_session
        expect(response).to have_http_status(200)
        expect(response.body).to include('Lazy dog')
      end
    end

    context 'without permission' do
      it 'returns authorization error' do
        get "/rspec/documents/#{document.id}/download", headers: rspec_session
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      it 'downloads current version' do
        get "/rspec/documents/#{document.id}/download", headers: rspec_session(admin)
        expect(response).to have_http_status(200)
        expect(response.body).to include('Lazy dog')
      end
    end
  end

  describe 'GET /rspec/documents/1/versions/1/download' do
    let(:document) { create :versioned_document }

    context 'with permission' do
      let!(:permission) { create :permission, code: 'document_show', account_user: AccountUser.last }
      it 'downloads previous version' do
        version = document.versions.last
        get "/rspec/documents/#{document.id}/versions/#{version.id}/download", headers: rspec_session
        expect(response).to have_http_status(200)
        expect(response.body).to include('Quick brown fox')
      end
    end

    context 'without permission' do
      it 'returns authorization error' do
        version = document.versions.last
        get "/rspec/documents/#{document.id}/versions/#{version.id}/download", headers: rspec_session
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      it 'downloads previous version' do
        version = document.versions.last
        get "/rspec/documents/#{document.id}/versions/#{version.id}/download", headers: rspec_session(admin)
        expect(response).to have_http_status(200)
        expect(response.body).to include('Quick brown fox')
      end
    end
  end

  describe 'PATCH /rspec/documents/1' do
    let(:document) { create :document, content: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/dog.txt')) }

    context 'with permission' do
      let!(:permission) { create :permission, code: :document_update, account_user: AccountUser.last }

      # it 'caches new file' do
      #   file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt'))
      #   patch "/rspec/documents/#{document.id}", headers: rspec_session,
      #                                            params: { content: file }
      #   expect(response).to have_http_status(200)
      #   expect(document.reload.content.data['storage']).to eq('cache')
      # end

      it 'updates attributes' do
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt'))
        patch "/rspec/documents/#{document.id}", headers: rspec_session,
                                                 params: {
                                                   data: {
                                                     id: document.id.to_s,
                                                     type: 'documents',
                                                     attributes: {
                                                       name: 'New name.txt' } } }.to_json
        expect(response).to have_http_status(200)
        Apartment::Tenant.switch('rspec') do
          expect(document.reload.name).to eq('New name.txt')
        end
      end
    end
  end

  describe 'POST /rspec/documents' do
    let(:params) {
      {
        data: {
          type: 'documents',
          attributes: {
            name: 'No content document'
          }
        }
      }
    }

    context 'with permission' do
      let!(:permission) { create :permission, code: 'document_create', account_user: AccountUser.last }
      it 'uploads a top-level document' do
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
        post '/rspec/documents', headers: rspec_session,
                                 params: params.to_json
        expect(response).to have_http_status(201)
      end
    end

    context 'guest with permission' do
      let!(:guest) { create :rspec_guest, set_permissions: [:document_create] }
      it 'returns authorization error' do
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
        post '/rspec/documents', headers: rspec_session(guest),
                                 params: params.to_json
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      let!(:document) { create :document }
      it 'creates a top-level document' do
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
        post '/rspec/documents', headers: rspec_session(admin),
                                 params: params.to_json
        expect(response).to have_http_status(201)
      end
    end

    context 'without permission' do
      it 'returns authorization error' do
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
        post '/rspec/documents', headers: rspec_session,
                                 params: params.to_json
        expect(response).to have_http_status(403)
      end
    end

    # TODO: Fix test once options re-implemented
    # context 'exceeding storage limit' do
    #   let!(:permission) { create :permission, code: :document_create, account_user: AccountUser.last }
    #   let!(:option) { create :option, name: :document_storage_limit, value: '1' }
    #   it 'returns unprocessable error' do
    #     file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
    #     post '/rspec/documents', headers: rspec_session,
    #                              params: { content: file }
    #     expect(response).to have_http_status(422)
    #   end
    # end
  end
end
