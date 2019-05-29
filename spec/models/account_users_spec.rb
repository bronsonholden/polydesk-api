require 'rails_helper'

describe AccountUser do
  describe 'rspec user' do
    let!(:user) { create :account_user }
    it 'correctly creates user' do
      account_user = AccountUser.last
      expect(user.role).to eq('user')
      expect(user.user.valid_password?('password')).to be true
      expect(user.user.accounts.size).to eq(1)
    end
  end

  describe 'rspec admin' do
    let!(:admin) { create :rspec_administrator }
    it 'correctly creates admin' do
      expect(admin.role).to eq('administrator')
      expect(admin.user.valid_password?('password')).to be true
      expect(admin.user.accounts.size).to eq(1)
    end
  end

  describe 'rspec guest' do
    let!(:guest) { create :rspec_guest }
    it 'correctly creates guest' do
      expect(guest.role).to eq('guest')
      expect(guest.user.valid_password?('password')).to be true
      expect(guest.user.accounts.size).to eq(1)
    end
  end

  describe 'created by factory' do
    let!(:account_user) { create :account_user }
    it 'links new user and account' do
      expect(account_user).not_to be_nil
      expect(account_user.user.valid_password?('password')).to be true
      expect(account_user.user.accounts.size).to eq(1)
    end
  end
end
