class AccountUser < ApplicationRecord
  validates :user_id, presence: true
  validates :account_id, presence: true, uniqueness: { scope: :user_id }
  belongs_to :user
  belongs_to :account
  has_many :permissions

  # Destroy all associated tenant records on delete, since there is no
  # foreign key used to relate them to the public AccountUser record.
  before_destroy { |record|
    record.permissions.destroy_all
  }

  # TODO: Bind to attribute
  # Useful for testing, at least
  def disabled?
    false
  end
end
