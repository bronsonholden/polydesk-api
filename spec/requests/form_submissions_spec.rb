require 'rails_helper'

RSpec.describe 'FormSubmissions', type: :request do
  let(:schema) {
    {
      type: 'object',
      properties: {
        name: { type: 'string' },
        email: { type: 'string' }
      },
      required: [ 'name', 'email' ]
    }.to_json
  }

  let!(:form) { create :form, schema: schema }

  let(:attributes) {
    {
      data: {
        name: 'John Doe',
        email: 'john@email.com'
      }
    }
  }

  let(:relationships) {
    {
      form: {
        data: {
          id: form.id.to_s,
          type: 'forms'
        }
      }
    }
  }

  let(:params) {
    {
      data: {
        type: 'form-submissions',
        attributes: attributes,
        relationships: relationships
      }
    }
  }

  describe 'GET /rspec/form-submissions' do
    let!(:permission) { create :permission, code: :form_submission_index, account_user: AccountUser.last }
    it 'retrieves all form submissions' do
      get '/rspec/form-submissions', headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /rspec/form-submissions/:id' do
    let(:submission) { create :form_submission, form: form }
    let!(:permission) { create :permission, code: :form_submission_show, account_user: AccountUser.last }
    it 'retrieves a form submission' do
      get "/rspec/form-submissions/#{submission.id}", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /rspec/form-submissions' do
    context 'with valid form data' do
      let!(:permission) { create :permission, code: :form_submission_create, account_user: AccountUser.last }
      it 'creates new form submission' do
        post '/rspec/form-submissions', headers: rspec_session,
                                        params: params.to_json
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid form data' do
      let!(:permission) { create :permission, code: :form_submission_create, account_user: AccountUser.last }
      let(:attributes) { {} }
      it 'rejects invalid form submissions' do
        post '/rspec/form-submissions', headers: rspec_session,
                                        params: params.to_json
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /rspec/form-submissions/:id' do
    let(:submission) { create :form_submission, form: form }
    let!(:permission) { create :permission, code: :form_submission_destroy, account_user: AccountUser.last }
    it 'deletes a form submission' do
      delete "/rspec/form-submissions/#{submission.id}", headers: rspec_session
      expect(response).to have_http_status(204)
    end
  end
end
