module Polydesk
  module Model
    module Validations
      module Document
        extend ActiveSupport::Concern

        included do
          validates :name, presence: true, format: {
            # Allow alphanumerals, spaces, and _ . - ( ) [ ]
            # The first character may not be a space, and the last must not be a space or period.
            with: /\A[A-Za-z0-9\-\(\)\[\]'_\.][A-Za-z0-9 \-\(\)\[\]'_\.]*[A-Za-z0-9\-\(\)\[\]'_]\z/,
            message: 'may only contain alphanumerals, spaces, or the following: _ . - ( ) [ ] and may not start with a space or end with either a space or .'
          }
          validates :name, uniqueness: { scope: [:folder_id, :unique_enforcer] },
                           unless: Proc.new { |doc| doc.unique_enforcer.nil? }
        end
      end
    end
  end
end
