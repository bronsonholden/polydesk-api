require 'rails_helper'

RSpec.describe AccountsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(:get => '/').to route_to('application#show')
    end
  end
end
