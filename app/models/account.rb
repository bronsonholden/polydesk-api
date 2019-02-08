class Account < ApplicationRecord
  include Rails.application.routes.url_helpers

  alias_attribute :account_identifier, :identifier
  alias_attribute :account_name, :name
  attr_readonly :identifier
  validates :identifier, uniqueness: true,
                         presence: true,
                         length: { minimum: 3, maximum: 20 },
                         format: {
                           with: /\A[a-z][a-z0-9]+\z/,
                           message: 'may only contain lowercase alphanumerals and must begin with a letter'
                         }
  validates :name, presence: true
  has_many :account_users
  has_many :users, through: :account_users, dependent: :destroy

  # Specify that we want to use identifier column when using URL helpers
  def to_param
    identifier
  end

  def related_users_url
    users_url(self)
  end
end
