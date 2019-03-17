class Form < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
