module Polydesk
  module ApiExceptions
    # The submitted form data does violates the schema of the form.
    class FormSchemaViolated < Polydesk::ApiExceptions::BaseException
    end
  end
end
