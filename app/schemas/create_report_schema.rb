class CreateReportSchema
  include SmartParams

  schema type: Strict::Hash do
    field :id, type: Strict::Nil
    field :controller, type: Strict::String.enum('reports')
    field :action, type: Strict::String.enum('create')
    field :data, type: Strict::Hash do
      field :type, type: Strict::String.enum('reports')
      field :attributes, type: Strict::Hash.optional do
        field :name, type: Strict::String.optional
      end
    end
  end
end
