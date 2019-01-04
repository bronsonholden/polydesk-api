class AccountUser < ApplicationRecord
  validates :user_id, presence: true
  validates :account_id, presence: true
  belongs_to :user
  belongs_to :account
  has_many :permissions

  # Destroy all associated tenant records on delete, since there is no
  # foreign key used to relate them to the public AccountUser record.
  before_destroy { |record|
    record.permissions.destroy_all
  }
end
