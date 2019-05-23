module Polydesk
  class AuthContext
    attr_reader :user, :identifier

    def initialize(user, identifier)
      @user = user
      @identifier = identifier
    end
  end
end
