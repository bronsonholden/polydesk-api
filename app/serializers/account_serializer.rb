class AccountSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :name, :identifier, :created_at, :updated_at
  has_many :users, lazy_load_data: true, links: {
    related: -> (object) {
      object.related_users_url
    }
  }
end
