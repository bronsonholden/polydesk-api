require 'rails_helper'

RSpec.describe AccountUsersController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/rspec/users').to route_to('account_users#create', identifier: 'rspec')
    end

    it 'routes to #index' do
      expect(get: '/rspec/users').to route_to('account_users#index', identifier: 'rspec')
    end

    it 'routes to #show' do
      expect(get: '/rspec/users/1').to route_to('account_users#show', id: '1', identifier: 'rspec')
    end

    it 'routes to #update' do
      expect(patch: '/rspec/users/1').to route_to('account_users#update', id: '1', identifier: 'rspec')
    end

    it 'routes to #destroy' do
      expect(delete: '/rspec/users/1').to route_to('account_users#destroy', id: '1', identifier: 'rspec')
    end
  end
end
