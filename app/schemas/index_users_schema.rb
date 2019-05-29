class IndexUsersSchema
  include SmartParams

  schema type: Strict::Hash do
    all_params
    field :id, type: Strict::Nil
    field :controller, type: Strict::String.enum('users')
    field :action, type: Strict::String.enum('index')
    field :data, type: Strict::Nil
  end
end
