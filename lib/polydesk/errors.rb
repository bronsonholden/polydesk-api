module Polydesk
  module Errors
    class Base < StandardError
      attr_reader :message, :status

      def initialize(message, status: :unprocessable_entity)
        @message = message
        @status = status
      end
    end

    class AccountIsDisabled < Polydesk::Errors::Base
      def initialize
        super('Account is disabled')
      end
    end

    class ClientGeneratedIdsForbidden < Polydesk::Errors::Base
      def initialize
        super('Client-generated IDs are forbidden')
      end
    end

    class ForbiddenAttributes < Polydesk::Errors::Base
      def initialize
        super('Attribute(s) forbidden')
      end
    end

    class ForbiddenRelationships < Polydesk::Errors::Base
      def initialize
        super('Relationship(s) forbidden')
      end
    end

    # The submitted form data does violates the schema of the form.
    class FormSchemaViolated < Polydesk::Errors::Base
      def initialize
        super('Form submission violates schema')
      end
    end

    class InvalidConfirmationToken < Polydesk::Errors::Base
      def initialize
        super('Confirmation token is invalid')
      end
    end

    class MalformedRequest < Polydesk::Errors::Base
      def initialize
        super('Request body is malformed')
      end
    end

    class NoAccountAccess < Polydesk::Errors::Base
      def initialize
        super('User does not have access to this account')
      end
    end

    class NotVersionable < Polydesk::Errors::Base
      def initialize
        super('Resource is not versionable')
      end
    end

    # The account has reached its storage limit and no new documents
    # may be uploaded.
    class StorageLimitReached < Polydesk::Errors::Base
      def initialize
        super('File storage limit reached')
      end
    end

    class UniqueFieldViolation < Polydesk::Errors::Base
      def initialize(key)
        super("Unique field violation: #{key}")
      end
    end
  end
end
