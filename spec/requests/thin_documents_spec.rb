require 'rails_helper'

RSpec.describe 'Documents', type: :request do
  describe 'GET /rspec/documents' do
    context 'with permission' do
      let!(:document) { create :document }
      let!(:permission) { create :permission, code: 'document_index', account_user: AccountUser.last }
      it 'retrieves all documents' do
        get '/rspec/documents', headers: rspec_session
        expect(response).to have_http_status(200)
        #expect(json).to be_array_of('document')
      end
    end

    # context 'admin without permission' do
    #   let!(:admin) { create :rspec_administrator }
    #   let!(:document) { create :document }
    #   it 'retrieves all documents' do
    #     get '/rspec/documents', headers: rspec_session(admin)
    #     expect(response).to have_http_status(200)
    #     expect(json).to be_array_of('document')
    #   end
    # end
    #
    # context 'without permission' do
    #   let!(:document) { create :document }
    #   it 'returns authorization error' do
    #     get '/rspec/documents', headers: rspec_session
    #     expect(response).to have_http_status(403)
    #     expect(json).to have_errors
    #   end
    # end
  end

  # describe 'GET /rspec/documents/1' do
  #   let!(:document) { create :document }
  #   let!(:permission) { create :permission, code: 'document_show', account_user: AccountUser.last }
  #   it 'retrieves document' do
  #     get "/rspec/documents/#{document.id}", headers: rspec_session
  #     expect(response).to have_http_status(200)
  #     expect(json).to be_a('document')
  #   end
  #
  #   context 'admin without permission' do
  #     let!(:admin) { create :rspec_administrator }
  #     let!(:document) { create :document }
  #     it 'retrieves document' do
  #       get "/rspec/documents/#{document.id}", headers: rspec_session(admin)
  #       expect(response).to have_http_status(200)
  #       expect(json).to be_a('document')
  #     end
  #   end
  # end
  #
  # describe 'DELETE /rspec/documents/1' do
  #   let!(:document) { create :document }
  #   let!(:permission) { create :permission, code: 'document_destroy', account_user: AccountUser.last }
  #   it 'deletes document' do
  #     delete "/rspec/documents/#{document.id}", headers: rspec_session
  #     expect(response).to have_http_status(204)
  #     document.reload
  #     expect(document.discarded_at).not_to be_nil
  #   end
  #
  #   context 'guest with permission' do
  #     let!(:guest) { create :rspec_guest, set_permissions: [:document_destroy] }
  #     let!(:document) { create :document }
  #     it 'returns authorization error' do
  #       delete "/rspec/documents/#{document.id}", headers: rspec_session(guest)
  #       expect(response).to have_http_status(403)
  #       expect(json).to have_errors
  #     end
  #   end
  #
  #   context 'admin without permission' do
  #     let!(:admin) { create :rspec_administrator }
  #     let!(:document) { create :document }
  #     it 'deletes document' do
  #       delete "/rspec/documents/#{document.id}", headers: rspec_session(admin)
  #       expect(response).to have_http_status(204)
  #       document.reload
  #       expect(document.discarded_at).not_to be_nil
  #     end
  #   end
  # end
  #
  # describe 'GET /rspec/documents/1/download' do
  #   context 'with permission' do
  #     let!(:permission) { create :permission, code: 'document_show', account_user: AccountUser.last }
  #     let!(:document) { create :versioned_document }
  #     it 'downloads current version' do
  #       get "/rspec/documents/#{document.id}/download", headers: rspec_session
  #       expect(response).to have_http_status(200)
  #       expect(response.body).to include('Lazy dog')
  #     end
  #   end
  #
  #   context 'without permission' do
  #     let!(:document) { create :versioned_document }
  #     it 'returns authorization error' do
  #       get "/rspec/documents/#{document.id}/download", headers: rspec_session
  #       expect(response).to have_http_status(403)
  #       expect(json).to have_errors
  #     end
  #   end
  #
  #   context 'admin without permission' do
  #     let!(:admin) { create :rspec_administrator }
  #     let!(:document) { create :versioned_document }
  #     it 'downloads current version' do
  #       get "/rspec/documents/#{document.id}/download", headers: rspec_session(admin)
  #       expect(response).to have_http_status(200)
  #       expect(response.body).to include('Lazy dog')
  #     end
  #   end
  # end
  #
  # describe 'GET /rspec/documents/1/versions/1/download' do
  #   context 'with permission' do
  #     let!(:permission) { create :permission, code: 'document_show', account_user: AccountUser.last }
  #     let!(:document) { create :versioned_document }
  #     it 'downloads previous version' do
  #       version = document.versions.last
  #       get "/rspec/documents/#{document.id}/versions/#{version.id}/download", headers: rspec_session
  #       expect(response).to have_http_status(200)
  #       expect(response.body).to include('Quick brown fox')
  #     end
  #   end
  #
  #   context 'without permission' do
  #     let!(:document) { create :versioned_document }
  #     it 'returns authorization error' do
  #       version = document.versions.last
  #       get "/rspec/documents/#{document.id}/versions/#{version.id}/download", headers: rspec_session
  #       expect(response).to have_http_status(403)
  #       expect(json).to have_errors
  #     end
  #   end
  #
  #   context 'admin without permission' do
  #     let!(:admin) { create :rspec_administrator }
  #     let!(:document) { create :versioned_document }
  #     it 'downloads previous version' do
  #       version = document.versions.last
  #       get "/rspec/documents/#{document.id}/versions/#{version.id}/download", headers: rspec_session(admin)
  #       expect(response).to have_http_status(200)
  #       expect(response.body).to include('Quick brown fox')
  #     end
  #   end
  # end
  #
  # describe 'PATCH /rspec/documents/1' do
  #   context 'with permission' do
  #     let!(:permission) { create :permission, code: :document_update, account_user: AccountUser.last }
  #     let!(:document) { create :document, content: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/dog.txt')) }
  #     it 'caches new file' do
  #       file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt'))
  #       patch "/rspec/documents/#{document.id}", headers: rspec_session,
  #                                                params: { content: file }
  #       expect(response).to have_http_status(200)
  #       expect(document.reload.content.data['storage']).to eq('cache')
  #       expect(json).to be_a('document')
  #     end
  #   end
  # end
  #
  # describe 'POST /rspec/documents' do
  #   context 'with permission' do
  #     let!(:permission) { create :permission, code: 'document_create', account_user: AccountUser.last }
  #     it 'uploads a top-level document' do
  #       file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
  #       post '/rspec/documents', headers: rspec_session,
  #                                params: { content: file }
  #       expect(response).to have_http_status(201)
  #       expect(json).to be_a('document')
  #     end
  #   end
  #
  #   context 'guest with permission' do
  #     let!(:guest) { create :rspec_guest, set_permissions: [:document_create] }
  #     it 'returns authorization error' do
  #       file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
  #       post '/rspec/documents', headers: rspec_session(guest),
  #                                params: { content: file }
  #       expect(response).to have_http_status(403)
  #       expect(json).to have_errors
  #     end
  #   end
  #
  #   context 'admin without permission' do
  #     let!(:admin) { create :rspec_administrator }
  #     let!(:document) { create :document }
  #     it 'uploads a top-level document' do
  #       file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
  #       post '/rspec/documents', headers: rspec_session(admin),
  #                                params: { content: file }
  #       expect(response).to have_http_status(201)
  #       expect(json).to be_a('document')
  #     end
  #   end
  #
  #   context 'without permission' do
  #     it 'returns authorization error' do
  #       file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
  #       post '/rspec/documents', headers: rspec_session,
  #                                params: { content: file }
  #       expect(response).to have_http_status(403)
  #       expect(json).to have_errors
  #     end
  #   end
  #
  #   context 'exceeding storage limit' do
  #     let!(:permission) { create :permission, code: :document_create, account_user: AccountUser.last }
  #     let!(:option) { create :option, name: :document_storage_limit, value: '1' }
  #     it 'returns unprocessable error' do
  #       file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf'))
  #       post '/rspec/documents', headers: rspec_session,
  #                                params: { content: file }
  #       expect(response).to have_http_status(422)
  #       expect(json).to have_errors
  #     end
  #   end
  # end
end
