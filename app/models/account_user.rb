class AccountUser < ApplicationRecord
  validates :user_id, presence: true
  validates :account_id, presence: true, uniqueness: { scope: :user_id }
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :account, class_name: 'User', foreign_key: 'account_id'
  has_many :permissions

  enum role: [
    :guest,
    :user,
    :administrator
  ]

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
