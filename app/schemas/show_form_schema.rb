class ShowFormSchema
  include SmartParams

  schema type: Strict::Hash do
    compounding_params
    sparse_params
    filter_params
    field :id, type: Strict::String
    field :controller, type: Strict::String.enum('forms')
    field :action, type: Strict::String.enum('show', 'destroy', 'restore')
    field :data, type: Strict::Nil
  end
end
