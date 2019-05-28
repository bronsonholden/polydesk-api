class ShowAccountSchema
  include SmartParams

  # Since account is specified as first param, but Realizers need an ID,
  # override the method to not pull the ID from request params but instead
  # find the account by identifier and return its ID.
  def id
    Account.find_by_identifier!(identifier).id.to_s
  end

  schema type: Strict::Hash do
    compounding_params
    sparse_params
    field :identifier, type: Strict::String
    field :id, type: Strict::Nil
    field :controller, type: Strict::String.enum('accounts')
    field :action, type: Strict::String.enum('show')
    field :data, type: Strict::Nil
  end
end
