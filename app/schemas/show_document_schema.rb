class ShowDocumentSchema
  include SmartParams

  schema type: Strict::Hash do
    compounding_params
    sparse_params
    filter_params
    field :id, type: Strict::String
    field :controller, type: Strict::String.enum('documents')
    field :action, type: Strict::String.enum('show', 'destroy', 'restore', 'download', 'download_version')
    field :version, type: Strict::String.optional
    field :data, type: Strict::Nil
  end
end
