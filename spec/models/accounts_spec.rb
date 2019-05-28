require 'rails_helper'

describe Account do
  describe 'created by factory' do
    context 'test' do
      let!(:account) { create :account }
      it 'succeeds' do
        expect(account).not_to be_nil
        expect(account.users.size).to eq(0)
      end
    end

    # This test makes sure post-test cleanup properly removes tenants that
    # aren't rspec
    context 'test2' do
      let!(:account) { create :account, identifier: 'test2' }
      it 'succeeds' do
        expect(account).not_to be_nil
        expect(account.users.size).to eq(0)
        expect(Account.find_by_identifier('rspec')).not_to be_nil
      end
    end
  end
end
