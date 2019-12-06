require 'rails_helper'

RSpec.describe 'Blueprints', type: :request do
  let(:attributes) {
    {
      name: 'A Blueprint',
      namespace: 'objects',
      schema: {
        type: 'object',
        properties: {
          field: {
            type: 'string'
          }
        }
      }
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

  describe 'POST /rspec/blueprints' do
    it 'creates new blueprint' do
      post '/rspec/blueprints', headers: rspec_session,
                                params: params.to_json
      expect(response).to have_http_status(201)
    end
  end
end
