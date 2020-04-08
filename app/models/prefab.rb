class Prefab < ApplicationRecord
  validates :data, presence: true
  validates :namespace, presence: true
  validates :tag, uniqueness: { scope: [:namespace] }, presence: true
  validates :schema, presence: true
  validates :view, presence: true
  belongs_to :blueprint, optional: true
  validate :check_schema

  before_validation :flatten_data
  before_validation :construction
  # Since namespace can be changed during Blueprint construction, the
  # auto_increment call must come after declaring the construction
  # lifecycle callback. This way the tag field is incremented after the
  # namespace has been modified.
  auto_increment :tag, scope: [:namespace], lock: true, force: true, before: :validation

  def check_schema
    JSON::Validator.validate!(self.schema, self.data)
  end

  def construction
    # If constructing (blueprint ref provided), assign everything except data
    if !self.blueprint.nil? && new_record?
      self.schema = self.blueprint.schema
      self.view = self.blueprint.view
      self.namespace = self.blueprint.namespace
    end
  end

  def flatten_data
    self.data ||= {}
    self.flat_data = Smush.smush(data)
  end
end
