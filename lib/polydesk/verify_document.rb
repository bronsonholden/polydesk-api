module Polydesk
  module VerifyDocument
    def within_storage_limit
      # Hardcoded limit for now
      limit = 1e9
      if Document.sum(:file_size) + self.file_size > limit
        raise Polydesk::ApiExceptions::DocumentException::StorageLimitReached.new(self)
      end
    end
  end
end
