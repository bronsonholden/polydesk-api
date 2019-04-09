module Polydesk
  module ApiExceptions
    class DocumentException < Polydesk::ApiExceptions::BaseException
      # The account has reached its storage limit and no new documents
      # may be uploaded.
      class StorageLimitReached < Polydesk::ApiExceptions::DocumentException
      end
    end
  end
end
