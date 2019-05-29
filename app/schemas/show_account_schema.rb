class ShowAccountSchema
  include SmartParams

  schema type: Strict::Hash do
    compounding_params
    sparse_params
    field :id, type: Strict::String
    field :controller, type: Strict::String.enum('accounts')
    field :action, type: Strict::String.enum('show')
    field :data, type: Strict::Nil
  end
end
