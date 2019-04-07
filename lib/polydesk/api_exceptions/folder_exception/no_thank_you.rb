module Polydesk
  module ApiExceptions
    class FolderException < Polydesk::ApiExceptions::BaseException
      # Example exception
      class NoThankYou < Polydesk::ApiExceptions::FolderException
      end
    end
  end
end
