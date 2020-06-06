class AccountUser < ApplicationRecord
  validates :user_id, presence: true
  validates :account_id, presence: true, uniqueness: { scope: :user_id }
  belongs_to :user
  belongs_to :account
  has_many :permissions
  has_many :account_user_groups
  has_many :groups, through: :account_user_groups, dependent: :destroy

  enum role: [
    :guest,
    :user,
    :administrator
  ]

  # TODO: Bind to attribute
  # Useful for testing, at least
  def disabled?
    false
  end
end
