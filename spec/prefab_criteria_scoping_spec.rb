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

  let(:data) {
    {
      name: 'John'
    }
  }

  let(:prefab) { create :prefab, data: data }
  let(:scope) { Polydesk::Blueprints::PrefabCriteriaScoping.apply(criteria, Prefab.where(id: prefab.id)) }

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

  context 'with property mismatch' do
    let(:data) {
      {
        name: 'Jane'
      }
    }

    it 'returns no results' do
      expect(scope.size).to eq(0)
    end
  end

  context 'with array key' do
    let(:data) {
      {
        people: ['John', 'Jane', 'Rob']
      }
    }

    let(:condition) {
      {
        operator: 'eq',
        operands: [
          {
            type: 'property',
            key: 'people[0]'
          },
          {
            type: 'literal',
            value: 'John'
          }
        ]
      }
    }

    it 'returns single result' do
      expect(scope.size).to eq(1)
    end
  end
end
