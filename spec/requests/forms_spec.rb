require 'rails_helper'

RSpec.describe 'Forms', type: :request do
  describe 'GET /rspec/forms' do
    context 'with permission' do
      let!(:form) { create :form }
      let!(:permission) { create :permission, code: :form_index, account_user: AccountUser.last }
      it 'retrieves all forms' do
        get '/rspec/forms', headers: rspec_session
        expect(response).to have_http_status(200)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      let!(:form) { create :form }
      it 'retrieves all forms' do
        get '/rspec/forms', headers: rspec_session(admin)
        expect(response).to have_http_status(200)
      end
    end

    context 'without permission' do
      let!(:form) { create :form }
      it 'returns authorization error' do
        get '/rspec/forms', headers: rspec_session
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'POST /rspec/forms' do
    context 'with permission' do
      let!(:permission) { create :permission, code: :form_create, account_user: AccountUser.last }
      it 'creates new form' do
        params = {
          name: 'RSpec Form',
          schema: {},
          layout: {}
        }
        post '/rspec/forms', headers: rspec_session, params: params.to_json
        expect(response).to have_http_status(201)
      end
    end

    context 'guest with permission' do
      let!(:guest) { create :rspec_guest, set_permissions: [:form_create] }
      it 'returns authorization error' do
        params = {
          name: 'RSpec Form',
          schema: {},
          layout: {}
        }
        post '/rspec/forms', headers: rspec_session(guest), params: params.to_json
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      it 'creates new form' do
        params = {
          name: 'RSpec Form',
          schema: {},
          layout: {}
        }
        post '/rspec/forms', headers: rspec_session(admin), params: params.to_json
        expect(response).to have_http_status(201)
      end
    end

    context 'without permission' do
      it 'returns authorization error' do
        params = {
          name: 'RSpec Form',
          schema: {},
          layout: {}
        }
        post '/rspec/forms', headers: rspec_session, params: params.to_json
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'PATCH /rspec/forms/1' do
    context 'with permission' do
      let!(:form) { create :form, name: 'Initial Name' }
      let!(:permission) { create :permission, code: :form_update, account_user: AccountUser.last }

      it 'updates form name' do
        patch "/rspec/forms/#{form.id}", headers: rspec_session,
                                         params: { name: 'Updated Name' }.to_json
        expect(response).to have_http_status(200)
        expect(form).to have_changed_attributes
      end

      it 'is idempotent' do
        patch "/rspec/forms/#{form.id}", headers: rspec_session,
                                         params: {}.to_json
        expect(response).to have_http_status(200)
        expect(form).not_to have_changed_attributes
      end

      it 'disallows blank form name' do
        patch "/rspec/forms/#{form.id}", headers: rspec_session,
                                         params: { name: '' }.to_json
        expect(response).to have_http_status(422)
      end
    end

    context 'guest with permission' do
      let!(:guest) { create :rspec_guest, set_permissions: [:form_update] }
      let!(:form) { create :form }
      it 'returns authorization error' do
        patch "/rspec/forms/#{form.id}", headers: rspec_session(guest),
                                         params: { name: 'Updated Name' }.to_json
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      let!(:form) { create :form, name: 'Initial Name' }
      it 'updates form name' do
        patch "/rspec/forms/#{form.id}", headers: rspec_session(admin),
                                         params: { name: 'Updated Name' }.to_json
        expect(response).to have_http_status(200)
        expect(form).to have_changed_attributes
      end
    end

    context 'without permission' do
      let!(:form) { create :form }
      it 'returns authorization error' do
        patch "/rspec/forms/#{form.id}", headers: rspec_session,
                                         params: { name: 'Updated Name' }.to_json
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'DELETE /rspec/forms/1' do
    context 'with permission' do
      let!(:form) { create :form }
      let!(:permission) { create :permission, code: :form_destroy, account_user: AccountUser.last }
      it 'destroys the form' do
        delete "/rspec/forms/#{form.id}", headers: rspec_session
        expect(response).to have_http_status(204)
      end
    end

    context 'guest with permission' do
      let!(:guest) { create :rspec_guest, set_permissions: [:form_destroy] }
      let!(:form) { create :form }
      it 'returns authorization error' do
        delete "/rspec/forms/#{form.id}", headers: rspec_session(guest)
        expect(response).to have_http_status(403)
      end
    end

    context 'admin without permission' do
      let!(:admin) { create :rspec_administrator }
      let!(:form) { create :form }
      it 'destroys the form' do
        delete "/rspec/forms/#{form.id}", headers: rspec_session(admin)
        expect(response).to have_http_status(204)
      end
    end

    context 'without permission' do
      let!(:form) { create :form }
      it 'returns authorization error' do
        delete "/rspec/forms/#{form.id}", headers: rspec_session
        expect(response).to have_http_status(403)
      end
    end
  end
end
