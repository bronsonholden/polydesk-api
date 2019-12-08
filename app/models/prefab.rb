class Prefab < ApplicationRecord
  auto_increment :tag, scope: [:namespace], lock: true, force: true, before: :validation
  validates :data, presence: true
  validates :namespace, presence: true
  validates :tag, uniqueness: { scope: [:namespace] }, presence: true
  validates :schema, presence: true
  validates :view, presence: true
  belongs_to :blueprint, optional: true
end
