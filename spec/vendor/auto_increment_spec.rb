require 'rails_helper'

describe 'auto_increment' do
  let(:prefab) { create :prefab, data: { foo: 'bar' } }

  describe 'id' do
    it 'does not change after creation' do
      id = prefab.id
      prefab.update!(data: { foo: 'baz' })
      expect(id).to eq(prefab.reload.id)
    end
  end
end
