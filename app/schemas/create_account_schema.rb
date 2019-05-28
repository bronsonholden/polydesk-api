class CreateAccountSchema
  include SmartParams

  schema type: Strict::Hash do
    field :id, type: Strict::Nil
    field :controller, type: Strict::String.enum('accounts')
    field :action, type: Strict::String.enum('create')
    field :data, type: Strict::Hash do
      field :type, type: Strict::String.enum('accounts')
      field :attributes, type: Strict::Hash.optional do
        field :bane, type: Strict::String.optional
        field :identifier, type: Strict::String.optional
      end
    end
  end
end
