require 'rails_helper'

describe User do
  describe 'created by factory' do
    let!(:user) { create :user }
    it 'succeeds' do
      expect(user).not_to be_nil
      # Account created by user factory and default RSpec account
      expect(User.all.size).to eq(2)
    end
  end
end
