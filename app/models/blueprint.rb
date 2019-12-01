class Blueprint < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :namespace, presence: true, uniqueness: true
  validates :schema, presence: true
end
