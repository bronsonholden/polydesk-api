require 'rails_helper'

RSpec.describe DocumentsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/rspec/documents').to route_to('documents#index', identifier: 'rspec')
    end

    it 'routes to #show' do
      expect(get: '/rspec/documents/1').to route_to('documents#show', id: '1', identifier: 'rspec')
    end

    it 'routes to #update via PUT' do
      expect(put: '/rspec/documents/1').to route_to('documents#update', id: '1', identifier: 'rspec')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/rspec/documents/1').to route_to('documents#update', id: '1', identifier: 'rspec')
    end

    it 'routes to #destroy' do
      expect(delete: '/rspec/documents/1').to route_to('documents#destroy', id: '1', identifier: 'rspec')
    end

    it 'routes to #folder' do
      expect(get: '/rspec/documents/1/folder').to route_to('documents#folder', id: '1', identifier: 'rspec')
    end
  end
end
