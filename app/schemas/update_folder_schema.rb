class UpdateFolderSchema
  include SmartParams

  schema type: Strict::Hash do
    field :id, type: Strict::String
    field :controller, type: Strict::String.enum('folders')
    field :action, type: Strict::String.enum('update')
    field :data, type: Strict::Hash do
      field :id, type: Strict::String
      field :type, type: Strict::String.enum('folders')
      field :attributes, type: Strict::Hash.optional do
        field :name, type: Strict::String.optional
      end
      field :relationships, type: Strict::Hash.optional do
        field :parent, type: Strict::Hash.optional do
          field :data, type: Strict::Hash.optional do
            field :id, type: Strict::String.optional
            field :type, type: Strict::String.enum('folders').optional
          end
        end
      end
    end
  end
end
