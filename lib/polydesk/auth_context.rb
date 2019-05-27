module Polydesk
  class AuthContext
    attr_reader :user, :account

    def initialize(user, account_identifier)
      @user = user
      @account = Account.find_by! account_identifier: account_identifier
    end
  end
end
