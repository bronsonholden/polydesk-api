require 'rails_helper'

RSpec.describe 'FormSubmissions', type: :request do
  describe 'GET /rspec/form-submissions' do
    it 'retrieves all form submissions' do
      get '/rspec/form-submissions', headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /rspec/form-submissions/:id' do
    let!(:submission) { create :form_submission }
    it 'retrieves a form submission' do
      get "/rspec/form-submissions/#{submission.id}", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /rspec/form-submissions' do
    let!(:form) { create :form, schema: {
        type: 'object',
        properties: {
          name: {
            type: 'string'
          },
          email: {
            type: 'string' } },
        required: [
          'name',
          'email'
        ] } }

    it 'creates new form submission' do
      post '/rspec/form-submissions', headers: rspec_session,
                                      params: {
                                        data: {
                                          type: 'form-submissions',
                                          attributes: {
                                            data: {
                                              name: 'John Doe',
                                              email: 'john@email.com' } },
                                          relationships: {
                                            form: {
                                              data: {
                                                id: form.id.to_s,
                                                type: 'forms' } } } }
                                      }.to_json
      expect(response).to have_http_status(201)
    end


    it 'rejects invalid form submissions' do
      post '/rspec/form-submissions', headers: rspec_session,
                                    params: {
                                      data: {
                                        type: 'form-submissions',
                                        attributes: {},
                                        relationships: {
                                          form: {
                                            data: {
                                              id: form.id.to_s,
                                              type: 'forms' } } } }
                                    }.to_json
      expect(response).to have_http_status(422)
    end
  end
end
