require 'rails_helper'

RSpec.describe Polydesk::Blueprints::PrefabCriteriaScoping do
  let(:condition) {
    {
      operator: 'eq',
      operands: [
        {
          type: 'property',
          key: 'name',
          object: 'self'
        },
        {
          type: 'literal',
          value: 'John'
        }
      ]
    }
  }

  let(:criteria) {
    {
      condition: condition
    }.to_json
  }

  let!(:prefab) { create :prefab, data: { name: 'John' } }
  let(:scope) { Polydesk::Blueprints::PrefabCriteriaScoping.apply(criteria, Prefab.all) }

  describe 'scoping' do
    it 'locates matching prefab' do
      expect(scope.size).to eq(1)
    end

    context 'with arbitrary condition' do
      let(:condition) {
        {
          operator: 'eq',
          operands: [
            {
              type: 'literal',
              value: 5
            },
            {
              type: 'literal',
              value: 5
            }
          ]
        }
      }

      it 'is unaffected' do
        expect(scope.size).to eq(1)
      end
    end
  end
end
