module Polydesk
  module VerifyDocument
    def within_storage_limit
      option = Option.find_by_name :document_storage_limit
      limit = (option.value.to_i unless option.nil?) || 1e9 # Hardcoded limit
      if Document.sum(:file_size) + self.file_size > limit
        raise Polydesk::ApiExceptions::DocumentException::StorageLimitReached.new(self)
      end
    end
  end
end
