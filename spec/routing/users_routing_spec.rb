require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(:get => '/rspec/users').to route_to('users#index', identifier: 'rspec')
    end

    it 'routes to #show' do
      expect(:get => '/rspec/users/1').to route_to('users#show', :id => '1', identifier: 'rspec')
    end

    it 'routes to #destroy' do
      expect(:delete => '/rspec/users/1').to route_to('users#destroy', :id => '1', identifier: 'rspec')
    end
  end
end
