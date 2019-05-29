require 'rails_helper'

describe User do
  describe 'created by factory' do
    let!(:user) { create :user }
    it 'succeeds' do
      expect(user).not_to be_nil
    end
  end
end
