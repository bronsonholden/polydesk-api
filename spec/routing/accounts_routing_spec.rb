require 'rails_helper'

RSpec.describe AccountsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(:get => '/rspec/account').to route_to('accounts#show', identifier: 'rspec')
    end

    it 'routes to #update via PUT' do
      expect(:put => '/rspec/account').to route_to('accounts#update', identifier: 'rspec')
    end

    it 'routes to #update via PATCH' do
      expect(:patch => '/rspec/account').to route_to('accounts#update', identifier: 'rspec')
    end
  end
end
