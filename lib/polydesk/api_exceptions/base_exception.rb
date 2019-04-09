module Polydesk
  module ApiExceptions
    class BaseException < StandardError
      attr_accessor :record, :status

      ERROR_DETAILS = {
        'FolderException::NoThankYou' => Proc.new { |record|
          record.errors.add('no', 'thank you')
          :unprocessable_entity
        },
        'DocumentException::StorageLimitReached' => Proc.new { |record|
          record.errors.add('document', 'storage limit reached')
          :unprocessable_entity
        }
      }

      def initialize(record)
        @record = record
        error_type = self.class.name.scan(/Polydesk::ApiExceptions::(.*)/).flatten.first
        @status = Polydesk::ApiExceptions::BaseException::ERROR_DETAILS.fetch(error_type).call(record)
        @status ||= :unprocessable_entity
      end
    end
  end
end
