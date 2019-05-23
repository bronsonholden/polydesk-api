module Polydesk
  class AuthContext
    attr_reader :user, :account

    def initialize(user, identifier)
      @user = user
      @account = User.find_by_identifier!(identifier)
    end
  end
end
