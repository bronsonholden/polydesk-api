require 'rails_helper'

describe AccountUser do
  describe 'rspec user' do
    it 'correctly creates user' do
      expect(AccountUser.last.role).to eq('administrator')
      expect(User.last.has_password?).to be true
    end
  end

  describe 'created by factory' do
    let!(:account_user) { create :account_user }
    it 'links test user and account' do
      expect(account_user).not_to be_nil
      expect(account_user.user.email).to eq('test@polydesk.io')
      expect(account_user.account.identifier).to eq('test')
    end
  end
end
