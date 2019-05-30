class UploadDocumentSchema
  include SmartParams

  schema type: Strict::Hash do
    field :content, type: Any
    field :name, type: Strict::String
  end
end
