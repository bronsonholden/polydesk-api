class AccountSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :name, :identifier
  has_many :users, lazy_load_data: true, links: {
    related: -> (object) {
      object.related_users_url
    }
  }
end
