class UpdateFormSubmissionSchema
  include SmartParams

  schema type: Strict::Hash do
    field :id, type: Strict::String
    field :controller, type: Strict::String.enum('form_submissions')
    field :action, type: Strict::String.enum('update')
    field :data, type: Strict::Hash do
      field :id, type: Strict::String
      field :type, type: Strict::String.enum('form-submissions')
      field :attributes, type: Strict::Hash.optional do
        field :data, type: Strict::String.Hash.optional
      end
    end
  end
end
