require 'rails_helper'

RSpec.describe 'Blueprints', type: :request do
  let(:name) { 'A Blueprint' }
  let(:namespace) { 'objects' }
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
  let(:construction_view) {
    {
      stub: true
    }
  }
  let(:attributes) {
    {
      name: name,
      namespace: namespace,
      schema: schema,
      view: view,
      construction_view: construction_view
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
  let(:blueprint) { create :blueprint, name: name, namespace: namespace, schema: schema, view: view, construction_view: construction_view }

  describe 'blueprint schema' do
    let(:name) { 'Employees' }
    let(:namespace) { 'employees' }
    let(:data) {
      {
        string: 'A string',
        prefab: 'employees/1'
      }
    }
    let(:employee_prefab) { create :prefab, blueprint: blueprint }
    it 'validates' do
      employee_prefab # Create the prefab that is being referenced
      expect { JSON::Validator.validate(blueprint.schema, data) }.not_to raise_error
    end

    describe 'validations' do
      let(:schema) {
        {
          type: 'object',
          properties: {
            "#{key}" => {
              type: 'string'
            }
          }
        }
      }
      context 'with invalid character(s)' do
        let(:key) { "invalid'key'name" }
        it 'raises error' do
          expect { blueprint }.to raise_error(Polydesk::Errors::InvalidBlueprintSchema)
        end
      end

      context 'with valid characters' do
        let(:key) { "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_" }
        it 'does not raise error' do
          expect { blueprint }.not_to raise_error
        end
      end
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
