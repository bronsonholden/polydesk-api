class AccountUser < ApplicationRecord
  validates :user_id, presence: true
  validates :account_id, presence: true
  belongs_to :user
  belongs_to :account
  has_many :permissions
end
