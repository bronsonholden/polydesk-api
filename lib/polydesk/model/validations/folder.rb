module Polydesk
  module Model
    module Validations
      module Folder
        extend ActiveSupport::Concern

        included do
          validates :name, presence: true, format: {
            # Allow alphanumerals, spaces, and _ . - ( ) [ ]
            # Spaces and . may not be the first or last character
            with: /\A[A-Za-z0-9 \-\(\)\[\]'"_\.,;:!\?@#\$%\^\&\*\{\}\+`~\|]+\z/,
            message: "may only contain alphanumerals, spaces, or the following symbols: _ . , ; : - ( ) [ ] { } ! ? @ # $ % ^ & * + ~ ` ' \" |"
          }

          # Enforce unique folder names (unless the folder is discarded---we
          # set unique_enforcer to NULL when discarding).
          validates :name, uniqueness: { scope: [:folder_id, :unique_enforcer] },
                           unless: Proc.new { |folder| folder.unique_enforcer.nil? }

          # We allow parent folder foreign key to be zero (indicating a
          # top-level folder).
          validates_each :folder_id do |record, attr, value|
            if !value.zero? && !::Folder.find_by_id(value)
              record.errors.add('folder', 'does not exist')
            end

            if value == record.id
              record.errors.add('folder', 'cannot contain itself')
            end
          end
        end
      end
    end
  end
end
