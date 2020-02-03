require 'rails_helper'

RSpec.describe 'Prefabs', type: :request do
  let(:view) { { stub: true } }
  let(:data) { { field: 'A String' } }

  let(:attributes) {
    {
      namespace: 'fields',
      schema: schema,
      view: view,
      data: data
    }
  }

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

  let(:blueprint) { create :blueprint, schema: schema,
                                        namespace: 'fields',
                                        name: 'Fields Blueprint' }

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

  describe 'creation' do
    shared_examples 'prefab_create_success' do
      it 'creates prefab' do
        blueprint # Create the blueprint so the relationship can be created
        post '/rspec/prefabs', headers: rspec_session,
                               params: params.to_json
        expect(response).to have_http_status(201)
      end
    end

    shared_examples 'prefab_create_failure' do
      it 'fails to create prefab' do
        blueprint # Create the blueprint so the relationship can be created
        post '/rspec/prefabs', headers: rspec_session,
                               params: params.to_json
        expect(response).to have_http_status(422)
      end
    end

    context 'constructed' do
      let(:params) {
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

      include_examples 'prefab_create_success'
    end

    context 'ad hoc' do
      let(:params) {
        {
          data: {
            type: 'prefabs',
            attributes: attributes
          }
        }
      }

      include_examples 'prefab_create_success'
    end

    context 'invalid' do
      # Invalid because we specify adhoc schema, view, etc. as well as
      # a Blueprint relationship
      let(:params) {
        {
          data: {
            type: 'prefabs',
            attributes: attributes,
            relationships: relationships
          }
        }
      }
    end
  end

  let(:prefab) { create :prefab }

  describe 'GET /rspec/prefabs' do
    it 'lists all prefabs' do
      get '/rspec/prefabs', headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /rspec/prefabs/:id' do
    it 'shows prefab' do
      get "/rspec/prefabs/#{prefab.id}", headers: rspec_session
      expect(response).to have_http_status(200)
    end
  end

  describe 'deferred properties' do
    let(:schema) {
      {
        type: 'object',
        properties: {
          field: {
            type: 'string'
          },
          other: {
            type: 'string',
            prefab: {
              namespace: 'fields',
              condition: {}
            }
          },
          defer: {
            type: 'string',
            defer: {
              reference: 'other',
              key: 'field'
            }
          }
        }
      }
    }

    let(:data) {
      {
        field: 'value'
      }
    }

    let(:prefab) { create :prefab, blueprint: blueprint, data: data }
    let(:defer_data) {
      {
        other: "#{prefab.namespace}/#{prefab.tag}"
      }
    }
    let(:defer_prefab) { create :prefab, blueprint: blueprint, data: defer_data }

    it 'applies deferred property' do
      prefab
      expect(defer_prefab.data.fetch('defer')).to eq('value')
    end
  end
end
