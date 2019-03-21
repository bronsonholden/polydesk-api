class Form < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :schema, presence: true
  validates :layout, presence: true
end
