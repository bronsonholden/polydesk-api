module Polydesk
  class AuthContext
    attr_reader :user, :account

    def initialize(user, identifier)
      @user = user
      @account = Account.find_by_identifier!(identifier)
    end
  end
end
