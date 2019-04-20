class AccountSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :identifier, :created_at, :updated_at

  attribute :discarded_at do |account|
    account.discarded_at || ''
  end

  has_many :users, lazy_load_data: true, links: {
    related: -> (object) {
      object.related_users_url
    }
  }
end
