require 'rails_helper'

describe Account do
  describe 'created by factory' do
    let!(:account) { create :account }
    it 'succeeds' do
      expect(account).not_to be_nil
      expect(account.users.size).to eq(0)
    end
  end
end
