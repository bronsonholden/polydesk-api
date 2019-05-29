class CreateFormSchema
  include SmartParams

  schema type: Strict::Hash do
    field :id, type: Strict::Nil
    field :controller, type: Strict::String.enum('forms')
    field :action, type: Strict::String.enum('create')
    field :data, type: Strict::Hash do
      field :type, type: Strict::String.enum('forms')
      field :attributes, type: Strict::Hash.optional do
        field :name, type: Strict::String.optional
        field :schema, type: Strict::Hash.optional
        field :layout, type: Strict::Hash.optional
      end
    end
  end
end
