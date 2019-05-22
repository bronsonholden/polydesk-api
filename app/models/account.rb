class Account < ApplicationRecord
  include Discard::Model

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
end
