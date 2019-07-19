module Polydesk
  module ApiExceptions
    class BaseException < StandardError
      attr_accessor :record, :status

      ERROR_DETAILS = {
        'AccountIsDisabled' => Proc.new { |record|
          record.errors.add(record.class.name.underscore, 'is disabled')
        },
        'InvalidConfirmationToken' => Proc.new { |record|
          record.errors.add('confirmation_token', 'is invalid')
        },
        'NotVersionable' => Proc.new { |record|
          record.errors.add(record.class.name.underscore, 'is not versionable')
        },
        'ClientGeneratedIdsForbidden' => Proc.new { |record|
        },
        'ForbiddenAttributes' => Proc.new { |record|
        },
        'ForbiddenRelationships' => Proc.new { |record|
        },
        'DocumentException::StorageLimitReached' => Proc.new { |record|
          record.errors.add('document', 'storage limit reached')
        },
        'UserException::NoAccountAccess' => Proc.new { |record|
          record.errors.add('user', 'does not have access to this account')
        },
        'FormSchemaViolated' => Proc.new { |record|
          record.errors.add('form_submission', 'violates form schema')
        }
      }

      def initialize(record = nil)
        @record = record
        error_type = self.class.name.scan(/Polydesk::ApiExceptions::(.*)/).flatten.first
        Polydesk::ApiExceptions::BaseException::ERROR_DETAILS.fetch(error_type).call(record)
      end
    end
  end
end
