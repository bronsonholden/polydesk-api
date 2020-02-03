# Processed deferred Prefab data properties. Deferred properties *copy* the
# current value of a referent Prefab's property when they are processed.
# Useful for maintaining historic values when referents change frequently,
# e.g. storing the price point of a purchased product at the time it was
# made, instead of showing the current price point.
#
# Deferred properties can be copied on Prefab creation and/or update.
#
# Example with deferred properties (copied only on create in this case):
#
# "schemas": {
#   "purchaseOrder": {
#     "type": "object",
#     "properties": {
#       "product": {
#         "type": "string",
#         "prefab": {
#           "namespace": "products"
#         }
#       },
#       "salePrice": {
#         "type": "number",
#         "defer": {
#           "reference": "product",
#           "key": "price",
#           "on": ["create"]
#         }
#       }
#     }
#   },
#   "product": {
#     "type": "object",
#     "properties": {
#       "name": {
#         "type": "string"
#       },
#       "price": {
#         "type": "number"
#       }
#     }
#   }
# }
class PrefabDefer
  attr_reader :prefab

  def initialize(prefab)
    @prefab = prefab
  end

  def apply
    schema = prefab.schema
    modified = prefab.data.deep_dup
    apply!(schema, nil, modified)
    modified
  end

  private

  def apply!(schema, key, data)
    if schema['type'] == 'object'
      subschemas = schema['properties']
      subschemas.each { |subkey, subschema|
        apply!(subschema, subkey, data)
      }
    elsif !key.nil? # Can't defer unless it's a property a JSON document
      defer = schema['defer']
      if !defer.nil?
        apply_defer(defer, key, data)
      end
    end
    data
  end

  def apply_defer(defer, key, data)
    reference = defer['reference']
    uid = prefab.data.dig(*reference.split('.'))
    return if uid.nil? # If reference key is not set, don't apply deferred properties
    m = uid.match(/^([a-z]+)\/(\d+)$/)
    namespace = m[1]
    tag = m[2]
    referent = Prefab.where(namespace: namespace, tag: tag).first
    referent_key = defer['key']
    val = referent.data.dig(*referent_key.split('.'))
    data[key] = val
  end
end
