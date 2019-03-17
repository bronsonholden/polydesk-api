require 'rails_helper'

RSpec.describe FormsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(:get => '/rspec/forms').to route_to('forms#index', identifier: 'rspec')
    end

    it 'routes to #show' do
      expect(:get => '/rspec/forms/1').to route_to('forms#show', :id => '1', identifier: 'rspec')
    end


    it 'routes to #create' do
      expect(:post => '/rspec/forms').to route_to('forms#create', identifier: 'rspec')
    end

    it 'routes to #update via PUT' do
      expect(:put => '/rspec/forms/1').to route_to('forms#update', :id => '1', identifier: 'rspec')
    end

    it 'routes to #update via PATCH' do
      expect(:patch => '/rspec/forms/1').to route_to('forms#update', :id => '1', identifier: 'rspec')
    end

    it 'routes to #destroy' do
      expect(:delete => '/rspec/forms/1').to route_to('forms#destroy', :id => '1', identifier: 'rspec')
    end
  end
end
