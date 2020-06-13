class Prefab < ApplicationRecord
  self.primary_key = 'id'
  list_partition_by :namespace
  validates :data, presence: true
  validates :namespace, presence: true, format: {
    with: /\A[a-z\-_0-9]+\z/,
    message: 'many only container lowercase letters, numbers, -, and _.'
  }
  validates :id, uniqueness: { scope: [:namespace] }, presence: true
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
  auto_increment :id, scope: [:namespace], lock: true, force: false, before: :validation
  attr_readonly :id

  def uid
    "#{namespace}/#{id}"
  end

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

  def self.partition_name(namespace)
    "prefabs_#{namespace}_partition"
  end

end
