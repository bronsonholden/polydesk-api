class Group < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :account_user_groups
  has_many :account_users, through: :account_user_groups, dependent: :destroy
  has_many :access_controls
end
