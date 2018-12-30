class Account < ApplicationRecord
  alias_attribute :account_identifier, :identifier
  alias_attribute :account_name, :name
  attr_readonly :identifier
  validates :identifier, uniqueness: true, presence: true, length: { minimum: 3, maximum: 20}
  validates :name, presence: true
  has_many :account_users
  has_many :users, through: :account_users, dependent: :destroy

  # Specify that we want to use identifier column when using URL helpers
  def to_param
    identifier
  end
end
