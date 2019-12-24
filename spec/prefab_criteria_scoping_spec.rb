require 'rails_helper'

RSpec.describe Polydesk::Blueprints::PrefabCriteriaScoping do
  let(:condition) {
    {}
  }

  let(:criteria) {
    {
      condition: condition
    }.to_json
  }

  let(:data) {
    {
      stub: true
    }
  }

  let(:prefab) { create :prefab, data: data }
  let(:scope) { Polydesk::Blueprints::PrefabCriteriaScoping.apply(criteria, Prefab.where(id: prefab.id)) }

  before(:each) do
    Polydesk::Blueprints::PrefabCriteriaSchema.validate!(criteria)
  end

  shared_examples 'scoping match' do
    it 'returns a match' do
      expect(scope.size).to eq(1)
    end
  end

  shared_examples 'scoping mismatch' do
    it 'returns no match' do
      expect(scope.size).to eq(0)
    end
  end

  describe 'operands' do
    describe 'property' do
      context 'integer key' do
        let(:data) {
          {
            '1' => 1
          }
        }

        let(:condition) {
          {
            operator: 'eq',
            operands: [
              {
                type: 'property',
                key: '1',
                cast: 'numeric',
                object: 'self'
              },
              {
                type: 'literal',
                value: 1
              }
            ]
          }
        }

        include_examples 'scoping match'
      end

      context 'array property' do
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
                key: 'people[0]',
                cast: 'text',
                object: 'self'
              },
              {
                type: 'literal',
                value: 'John'
              }
            ]
          }
        }

        include_examples 'scoping match'
      end
    end
  end

  describe 'operators' do
    describe 'arithmetic' do
      describe 'add' do
        let(:data) {
          {
            left: 2,
            right: 2
          }
        }
        let(:condition) {
          {
            operator: 'eq',
            operands: [
              {
                operator: 'add',
                operands: [
                  {
                    type: 'property',
                    key: 'left',
                    cast: 'numeric',
                    object: 'self'
                  },
                  {
                    type: 'property',
                    key: 'right',
                    cast: 'numeric',
                    object: 'self'
                  }
                ]
              },
              {
                type: 'literal',
                value: 4
              }
            ]
          }
        }

        include_examples 'scoping match'
      end

      describe 'sub' do
        let(:data) {
          {
            left: 10,
            right: 20
          }
        }
        let(:condition) {
          {
            operator: 'eq',
            operands: [
              {
                operator: 'sub',
                operands: [
                  {
                    type: 'property',
                    key: 'left',
                    cast: 'numeric',
                    object: 'self'
                  },
                  {
                    type: 'property',
                    key: 'right',
                    cast: 'numeric',
                    object: 'self'
                  }
                ]
              },
              {
                type: 'literal',
                value: -10
              }
            ]
          }
        }

        include_examples 'scoping match'
      end
    end

    describe 'logical' do
      describe 'eq' do
        context 'string property' do
          let(:data) {
            {
              name: 'John'
            }
          }
          let(:condition) {
            {
              operator: 'eq',
              operands: [
                {
                  type: 'property',
                  key: 'name',
                  cast: 'text',
                  object: 'self'
                },
                {
                  type: 'literal',
                  value: 'John'
                }
              ]
            }
          }
          include_examples 'scoping match'
        end
      end
    end
  end

  describe 'static condition' do
    context 'when true' do
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

      include_examples 'scoping match'
    end

    context 'when false' do
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
              value: 0
            }
          ]
        }
      }

      include_examples 'scoping mismatch'
    end
  end
end
