require 'rails_helper'

RSpec.describe 'Prefabs', type: :request do
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
  let!(:blueprint) { create :blueprint, schema: schema,
                                        namespace: 'fields',
                                        name: 'Fields Blueprint' }
  let(:view) {
    {
      stub: true
    }
  }
  let(:data) {
    {
      field: 'A String'
    }
  }
  let(:attributes) {
    {
      namespace: 'fields',
      schema: schema,
      view: view,
      data: data
    }
  }
  let(:relationships) {
    {
      blueprint: {
        data: {
          id: blueprint.id.to_s,
          type: 'blueprints'
        }
      }
    }
  }
  let(:constructed_params) {
    {
      data: {
        type: 'prefabs',
        attributes: {
          data: data
        },
        relationships: relationships
      }
    }
  }
  let(:adhoc_params) {
    {
      data: {
        type: 'prefabs',
        attributes: attributes
      }
    }
  }
  let(:prefab) { create :prefab }

  describe 'GET /rspec/prefabs' do
    it 'lists all prefabs' do
      get '/rspec/prefabs', headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /rspec/prefabs/:id' do
    let(:prefab) { create :prefab }
    it 'shows prefab' do
      get "/rspec/prefabs/#{prefab.id}", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /rspec/prefabs' do
    it 'creates constructed prefab' do
      post '/rspec/prefabs', headers: rspec_session,
                             params: constructed_params.to_json
      expect(response).to have_http_status(201)
    end

    it 'creates adhoc prefab' do
      post '/rspec/prefabs', headers: rspec_session,
                             params: adhoc_params.to_json
      expect(response).to have_http_status(201)
    end
  end
end
