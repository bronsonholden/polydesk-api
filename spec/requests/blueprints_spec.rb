require 'rails_helper'

RSpec.describe 'Blueprints', type: :request do
  let(:schema) {
    {
      type: 'object',
      properties: {
        field: {
          type: 'string'
        }
      }
    }
  }
  let(:view) {
    {
      stub: true
    }
  }
  let(:attributes) {
    {
      name: 'A Blueprint',
      namespace: 'objects',
      schema: schema,
      view: view
    }
  }
  let(:params) {
    {
      data: {
        type: 'blueprints',
        attributes: attributes
      }
    }
  }
  let(:blueprint) { create :blueprint }

  describe 'blueprint schema' do
    let(:data) {
      {
        string: 'A string',
        prefab: 'employees/1'
      }
    }
    it 'validates' do
      expect { JSON::Validator.validate(blueprint.schema, data) }.not_to raise_error
    end
  end

  describe 'GET /rspec/blueprints' do
    it 'lists all blueprints' do
      get '/rspec/blueprints', headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /rspec/blueprints/:id' do
    let(:blueprint) { create :blueprint }
    it 'shows blueprint' do
      get "/rspec/blueprints/#{blueprint.id}", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /rspec/blueprints' do
    it 'creates new blueprint' do
      post '/rspec/blueprints', headers: rspec_session,
                                params: params.to_json
      expect(response).to have_http_status(201)
    end

    context 'with valid prefab schema attribute' do
      let(:schema) {
        {
          type: 'object',
          properties: {
            field: {
              type: 'string',
              prefab: {
                namespace: 'employees'
              }
            }
          }
        }
      }
      it 'creates new blueprint' do
        post '/rspec/blueprints', headers: rspec_session,
                                  params: params.to_json
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid prefab schema attribute' do
      let(:schema) {
        {
          type: 'object',
          properties: {
            field: {
              type: 'string',
              prefab: 'not-prefab-schema'
            }
          }
        }
      }
      it 'creates new blueprint' do
        post '/rspec/blueprints', headers: rspec_session,
                                  params: params.to_json
        expect(response).to have_http_status(422)
      end
    end
  end
end
