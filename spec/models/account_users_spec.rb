require 'rails_helper'

describe AccountUser do
  describe 'created by factory' do
    let!(:account_user) { create :account_user }
    it 'links test user and account' do
      expect(account_user).not_to be_nil
      expect(account_user.user.email).to eq('test@polydesk.io')
      expect(account_user.account.identifier).to eq('test')
    end
  end
end
