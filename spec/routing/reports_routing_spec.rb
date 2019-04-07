require 'rails_helper'

RSpec.describe ReportsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/rspec/reports').to route_to('reports#index', identifier: 'rspec')
    end

    it 'routes to #show' do
      expect(get: '/rspec/reports/1').to route_to('reports#show', id: '1', identifier: 'rspec')
    end


    it 'routes to #create' do
      expect(post: '/rspec/reports').to route_to('reports#create', identifier: 'rspec')
    end

    it 'routes to #update via PUT' do
      expect(put: '/rspec/reports/1').to route_to('reports#update', id: '1', identifier: 'rspec')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/rspec/reports/1').to route_to('reports#update', id: '1', identifier: 'rspec')
    end

    it 'routes to #destroy' do
      expect(delete: '/rspec/reports/1').to route_to('reports#destroy', id: '1', identifier: 'rspec')
    end
  end
end
