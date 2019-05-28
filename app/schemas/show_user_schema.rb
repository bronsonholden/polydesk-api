class ShowUserSchema
  include SmartParams

  schema type: Strict::Hash do
    compounding_params
    sparse_params
    field :id, type: Strict::String
    field :controller, type: Strict::String.enum('users')
    field :action, type: Strict::String.enum('show')
    field :data, type: Strict::nil
  end
end
