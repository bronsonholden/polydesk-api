module Polydesk
  module VerifyDocument
    def within_storage_limit
      # Hardcoded limit for now
      limit = 1e9
      # Allow no-content documents
      return if self.file_size.nil?
      # Verify within storage limit
      if Document.sum(:file_size) + self.file_size > limit
        raise Polydesk::DocumentException::StorageLimitReached.new(self)
      end
    end
  end
end
