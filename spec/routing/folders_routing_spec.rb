require 'rails_helper'

RSpec.describe FormsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/rspec/folders').to route_to('folders#index', identifier: 'rspec')
    end

    it 'routes to #show' do
      expect(get: '/rspec/folders/1').to route_to('folders#show', id: '1', identifier: 'rspec')
    end

    it 'routes to #create' do
      expect(post: '/rspec/folders').to route_to('folders#create', identifier: 'rspec')
    end

    it 'routes to #update via PUT' do
      expect(put: '/rspec/folders/1').to route_to('folders#update', id: '1', identifier: 'rspec')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/rspec/folders/1').to route_to('folders#update', id: '1', identifier: 'rspec')
    end

    it 'routes to #destroy' do
      expect(delete: '/rspec/folders/1').to route_to('folders#destroy', id: '1', identifier: 'rspec')
    end

    it 'routes to #folders' do
      expect(get: '/rspec/folders/1/folders').to route_to('folders#folders', id: '1', identifier: 'rspec')
    end

    it 'routes to #documents' do
      expect(get: '/rspec/folders/1/documents').to route_to('folders#documents', id: '1', identifier: 'rspec')
    end

    it 'routes to #add_folder' do
      expect(post: '/rspec/folders/1/folders').to route_to('folders#add_folder', id: '1', identifier: 'rspec')
    end

    it 'routes to #add_document' do
      expect(post: '/rspec/folders/1/documents').to route_to('folders#add_document', id: '1', identifier: 'rspec')
    end
  end
end
