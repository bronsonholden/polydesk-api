class UpdateFormSchema
  include SmartParams

  schema type: Strict::Hash do
    field :id, type: Strict::String
    field :controller, type: Strict::String.enum('forms')
    field :action, type: Strict::String.enum('update')
    field :data, type: Strict::Hash do
      field :id, type: Strict::String
      field :type, type: Strict::String.enum('forms')
      field :attributes, type: Strict::Hash.optional do
        field :name, type: Strict::String.optional
      end
    end
  end
end
