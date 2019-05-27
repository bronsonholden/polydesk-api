class CreateAccountSchema
  include SmartParams

  schema type: Strict::Hash do
    field :id, type: Strict::Nil
    field :controller, type: Strict::String.enum('accounts')
    field :action, type: Strict::String.enum('create')
    field :data, type: Strict::Hash do
      field :type, type: Strict::String.enum('accounts')
      field :attributes, type: Strict::Hash.optional do
        field :account_name, type: Strict::String.optional
        field :account_identifier, type: Strict::String.optional
        field :name, type: Strict::String.optional
        field :email, type: Strict::String.optional
        field :password, type: Strict::String.optional
        field :password_confirmation, type: Strict::String.optional
      end
    end
  end
end
