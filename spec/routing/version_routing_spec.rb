require 'rails_helper'

RSpec.describe VersionsController, type: :routing do
  describe 'routing' do
    context 'for documents' do
      it 'routes to #index' do
        expect(get: '/rspec/documents/1/versions').to route_to('versions#index', model: 'documents', id: '1', identifier: 'rspec')
      end

      it 'routes to #show' do
        expect(get: '/rspec/documents/1/versions/1').to route_to('versions#show', model: 'documents', id: '1', identifier: 'rspec', version: '1')
      end

      it 'routes to #restore' do
        expect(put: '/rspec/documents/1/versions/1').to route_to('versions#restore', model: 'documents', id: '1', identifier: 'rspec', version: '1')
      end
    end

    context 'for folders' do
      it 'routes to #index' do
        expect(get: '/rspec/folders/1/versions').to route_to('versions#index', model: 'folders', id: '1', identifier: 'rspec')
      end

      it 'routes to #show' do
        expect(get: '/rspec/folders/1/versions/1').to route_to('versions#show', model: 'folders', id: '1', identifier: 'rspec', version: '1')
      end

      it 'routes to #restore' do
        expect(put: '/rspec/folders/1/versions/1').to route_to('versions#restore', model: 'folders', id: '1', identifier: 'rspec', version: '1')
      end
    end
  end
end
