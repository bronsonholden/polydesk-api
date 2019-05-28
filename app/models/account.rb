class Account < ApplicationRecord
  attr_readonly :identifier
  validates :identifier, uniqueness: true,
                         presence: true,
                         length: { minimum: 3, maximum: 20 },
                         format: {
                           with: /\A[a-z][a-z\-_0-9][a-z0-9]+\z/,
                           message: 'many only container lowercase letters, numbers, -, and _ and must start and end with a lowercase letter or number.'
                         }
  validates :name, presence: true

  has_many :account_users
  has_many :users, through: :account_users, dependent: :destroy
end
