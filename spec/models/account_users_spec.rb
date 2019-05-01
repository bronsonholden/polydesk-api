require 'rails_helper'

describe AccountUser do
  describe 'rspec user' do
    it 'correctly creates user' do
      user = User.find_by_email('rspec@polydesk.io')
      account_user = AccountUser.where(user_id: user.id).first
      expect(account_user.role).to eq('user')
      expect(user.has_password?).to be true
      expect(user.valid_password?('password')).to be true
    end
  end

  describe 'rspec admin' do
    let!(:admin) { create :rspec_administrator }
    it 'correctly creates admin' do
      expect(admin.role).to eq('administrator')
      expect(admin.user.valid_password?('password')).to be true
    end
  end

  describe 'rspec guest' do
    let!(:guest) { create :rspec_guest }
    it 'correctly creates guest' do
      expect(guest.role).to eq('guest')
      expect(guest.user.valid_password?('password')).to be true
    end
  end

  describe 'created by factory' do
    let!(:account_user) { create :account_user }
    it 'links new user and account' do
      expect(account_user).not_to be_nil
      expect(account_user.user.email).to eq('rspec_user@polydesk.io')
      expect(account_user.user.valid_password?('password')).to be true
      expect(account_user.account.identifier).to eq('rspec')
    end
  end
end
