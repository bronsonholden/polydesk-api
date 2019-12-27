require 'rails_helper'

RSpec.describe Polydesk::Blueprints::PrefabCriteriaSchema do
  let(:valid?) { Polydesk::Blueprints::PrefabCriteriaSchema.validate(criteria) }

  let(:criteria) {
    {
      condition: condition
    }.to_json
  }

  let(:neq_condition) {
    {
      operator: 'neq',
      operands: [
        {
          type: 'literal',
          value: 1
        },
        {
          type: 'literal',
          value: 2
        }
      ]
    }
  }

  let(:eq_condition) {
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

  let(:and_condition) {
    {
      operator: 'and',
      operands: [
        eq_condition,
        neq_condition
      ]
    }
  }

  let(:or_condition) {
    {
      operator: 'or',
      operands: [
        eq_condition,
        neq_condition
      ]
    }
  }

  let(:not_condition) {
    {
      operator: 'not',
      operand: and_condition
    }
  }

  describe 'logical' do
    context 'valid and condition' do
      let(:condition) { and_condition }
      it 'validates' do
        expect(valid?).to eq(true)
      end
    end

    context 'valid or condition' do
      let(:condition) { or_condition }
      it 'validates' do
        expect(valid?).to eq(true)
      end
    end

    context 'valid not condition' do
      let(:condition) { not_condition }
      it 'validates' do
        expect(valid?).to eq(true)
      end
    end
  end

  describe 'relational operators' do
    context 'valid eq condition' do
      let(:condition) { eq_condition }
      it 'validates' do
        expect(valid?).to eq(true)
      end
    end

    context 'valid neq condition' do
      let(:condition) { neq_condition }
      it 'validates' do
        expect(valid?).to eq(true)
      end
    end
  end
end
