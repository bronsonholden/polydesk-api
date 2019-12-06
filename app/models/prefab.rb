class Prefab < ApplicationRecord
  auto_increment :tag, scope: [:namespace], lock: true, force: true
  validates :data, presence: true
  validates :namespace, presence: true
  validates :tag, uniqueness: { scope: [:namespace] }, presence: true
  validates :schema, presence: true
  validates :view, presence: true
end
