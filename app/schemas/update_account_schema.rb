class UpdateAccountSchema
  include SmartParams

  def id
    Account.find_by_identifier!(identifier).id.to_s
  end

  schema type: Strict::Hash do
    field :id, type: Strict::Nil
    field :identifier, type: Strict::String
    field :controller, type: Strict::String.enum('accounts')
    field :action, type: Strict::String.enum('update')
    field :data, type: Strict::Hash do
      field :id, type: Strict::String
      field :type, type: Strict::String.enum('accounts')
      field :attributes, type: Strict::Hash.optional do
        field :name, type: Strict::String.optional
      end
    end
  end
end
