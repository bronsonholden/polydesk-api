class CreateDocumentSchema
  include SmartParams

  schema type: Strict::Hash do
    field :id, type: Strict::Nil
    field :controller, type: Strict::String.enum('documents')
    field :action, type: Strict::String.enum('create')
    field :data, type: Strict::Hash do
      field :type, type: Strict::String.enum('documents')
      field :attributes, type: Strict::Hash.optional do
        field :name, type: Strict::String.optional
      end
      field :relationships, type: Strict::Hash.optional do
        field :folder, type: Strict::Hash.optional do
          field :data, type: Strict::Hash.optional do
            field :id, type: Strict::String.optional
            field :type, type: Strict::String.enum('folders').optional
          end
        end
      end
    end
  end
end
