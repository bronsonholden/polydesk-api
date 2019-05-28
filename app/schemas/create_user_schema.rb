class CreateUserSchema
  include SmartParams

  schema type: Strict::Hash do
    field :id, type: Strict::Nil
    field :controller, type: Strict::String.enum('users')
    field :action, type: Strict::String.enum('create')
    field :data, type: Strict::Hash do
      field :type, type: Strict::String.enum('users')
      field :attributes, type: Strict::Hash do
        field :first_name, type: Strict::String.optional
        field :last_name, type: Strict::String.optional
        field :email, type: Strict::String
        field :password, type: Strict::String
        field :password_confirmation, type: Strict::String
      end
      field :relationships, type: Strict::Hash.optional do
        field :accounts, type: Strict::Hash.optional do
          field :data, type: Strict::Hash.optional do
            field :id, type: Strict::String.optional
            field :type, type: Strict::String.enum('accounts').optional
          end
        end
      end
    end
  end
end
