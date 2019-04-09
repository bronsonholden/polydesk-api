module Polydesk
  module VerifyDocument
    def within_storage_limit
      if Document.sum(:file_size) + self.file_size > 1e9
        raise Polydesk::ApiExceptions::DocumentException::StorageLimitReached.new(self)
      end
    end
  end
end
