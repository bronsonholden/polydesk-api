require 'rails_helper'

describe Prefab do
  let(:prefab) { create :prefab, data: { foo: 'bar' } }

  describe 'tag' do
    it 'does not change after creation' do
      tag = prefab.tag
      prefab.update!(data: { foo: 'baz' })
      expect(tag).to eq(prefab.reload.tag)
    end

    it 'does not change when updated' do
      tag = prefab.tag
      prefab.update!(tag: tag + 1)
      expect(tag).to eq(prefab.reload.tag)
    end
  end
end
