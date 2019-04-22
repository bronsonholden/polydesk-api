require 'rails_helper'

RSpec.describe PermissionsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/rspec/users/1/permissions').to route_to('permissions#index', id: '1', identifier: 'rspec')
    end

    it 'routes to #create' do
      expect(post: '/rspec/users/1/permissions').to route_to('permissions#create', id: '1', identifier: 'rspec')
    end

    it 'routes to #destroy' do
      expect(delete: '/rspec/users/1/permissions').to route_to('permissions#destroy', id: '1', identifier: 'rspec')
    end
  end
end
