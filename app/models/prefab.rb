class Prefab < ApplicationRecord
  validates :data, presence: true
  validates :namespace, presence: true
  validates :tag, uniqueness: { scope: [:namespace] }, presence: true
  validates :schema, presence: true
  validates :view, presence: true
end
