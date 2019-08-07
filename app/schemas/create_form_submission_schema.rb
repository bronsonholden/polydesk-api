class CreateFormSubmissionSchema
  include SmartParams

  schema type: Strict::Hash do
    field :id, type: Strict::Nil
    field :controller, type: Strict::String.enum('form_submissions')
    field :action, type: Strict::String.enum('create')
    field :data, type: Strict::Hash do
      field :type, type: Strict::String.enum('form-submissions')
      field :attributes, type: Strict::Hash.optional do
        field :data, type: Strict::Hash.optional
        field :state, type: Strict::String.enum('draft', 'published').optional
      end
      field :relationships, type: Strict::Hash.optional do
        field :form, type: Strict::Hash.optional do
          field :data, type: Strict::Hash do
            field :id, type: Strict::String
            field :type, type: Strict::String.enum('forms')
          end
        end
      end
    end
  end
end
