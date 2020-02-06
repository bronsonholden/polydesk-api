class Prefab < ApplicationRecord
  validates :data, presence: true
  validates :namespace, presence: true
  validates :tag, uniqueness: { scope: [:namespace] }, presence: true
  validates :schema, presence: true
  validates :view, presence: true
  belongs_to :blueprint, optional: true
  validate :check_schema

  before_validation :construction, :defer_data
  # Since namespace can be changed during Blueprint construction, the
  # auto_increment call must come after declaring the construction
  # lifecycle callback. This way the tag field is incremented after the
  # namespace has been modified.
  auto_increment :tag, scope: [:namespace], lock: true, force: true, before: :validation

  def check_schema
    valid = JSON::Validator.validate(self.schema, self.data)
    raise Polydesk::Errors::FormSchemaViolated.new if !valid
    check_prefab_references_valid(schema, data)
  end

  def construction
    # If constructing (blueprint ref provided), assign everything except data
    if !self.blueprint.nil? && new_record?
      self.schema = self.blueprint.schema
      self.view = self.blueprint.view
      self.namespace = self.blueprint.namespace
    end
  end

  def defer_data
    if new_record?
      self.data = PrefabDefer.new(self).apply
    end
  end

  def check_prefab_references_valid(schema, data)
    prefab = schema['prefab']
    type = schema['type']
    if type == 'string' && !prefab.nil?
      m = data.match(/^([a-z]+)\/(\d+)$/)
      if !m.nil?
        namespace = m[1]
        tag = m[2]
        reference = Prefab.where(namespace: namespace, tag: tag)
        scope = PrefabCriteriaScoping.apply(prefab.to_json, reference)
        if !scope.any?
          raise Polydesk::Errors::PrefabCriteriaNotMet.new("#{reference.first.namespace}/#{reference.first.tag} does not meet criteria for reference")
        end
      end
    elsif type == 'object'
      schema.fetch('properties', {}).each { |prop, subschema|
        check_prefab_references_valid(subschema, data.fetch(prop, {}))
      }
    end
  end
end
