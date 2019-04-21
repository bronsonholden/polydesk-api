module Polydesk
  module ApiExceptions
    class UserException < Polydesk::ApiExceptions::BaseException
      class NoAccountAccess < Polydesk::ApiExceptions::UserException
      end
    end
  end
end
