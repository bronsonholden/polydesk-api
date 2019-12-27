module Polydesk
  module Blueprints
    # This validates a prefab criteria subschema (specified as "prefab" in
    # the blueprint schema).
    class PrefabCriteriaSchema
      def self.validate(schema)
        JSON::Validator.validate(self.schema, schema)
      end

      def self.validate!(schema)
        JSON::Validator.validate!(self.schema, schema)
      end

      def self.schema
        {
          definitions: {
            operators: {
              '$boolean_expression' => {
                oneOf: [
                  { '$ref' => '#/definitions/operators/relational/$one' },
                  { '$ref' => '#/definitions/operators/logical/$one' }
                ]
              },
              relational: {
                '$one' => {
                  oneOf: [
                    { '$ref' => '#/definitions/operators/relational/eq_neq' }
                  ]
                },
                eq_neq: {
                  type: 'object',
                  required: ['operator', 'operands'],
                  properties: {
                    operator: {
                      type: 'string',
                      enum: ['eq', 'neq']
                    },
                    operands: {
                      type: 'array',
                      items: {
                        '$ref' => '#/definitions/operands/$one'
                      },
                      minItems: 2,
                      maxItems: 2
                    }
                  }
                }
              },
              arithmetic: {
                '$one' => {
                  oneOf: [
                    { '$ref' => '#/definitions/operators/arithmetic/add' },
                    { '$ref' => '#/definitions/operators/arithmetic/sub' }
                  ]
                },
                add: {
                  type: 'object',
                  required: ['operator', 'operands'],
                  properties: {
                    operator: {
                      type: 'string',
                      enum: ['add']
                    },
                    operands: {
                      type: 'array',
                      items: {
                        '$ref' => '#/definitions/operands/$one'
                      }
                    }
                  }
                },
                sub: {
                  type: 'object',
                  required: ['operator', 'operands'],
                  properties: {
                    operator: {
                      type: 'string',
                      enum: ['sub']
                    },
                    operands: {
                      type: 'array',
                      items: {
                        '$ref' => '#/definitions/operands/$one'
                      }
                    }
                  }
                }
              },
              logical: {
                '$one' => {
                  oneOf: [
                    { '$ref' => '#/definitions/operators/logical/and_or' },
                    { '$ref' => '#/definitions/operators/logical/not' }
                  ]
                },
                not: {
                  type: 'object',
                  required: ['operator', 'operand'],
                  properties: {
                    operator: {
                      type: 'string',
                      enum: ['not']
                    },
                    operand: {
                      '$ref' => '#/definitions/operators/$boolean_expression'
                    }
                  }
                },
                and_or: {
                  type: 'object',
                  required: ['operator', 'operands'],
                  properties: {
                    operator: {
                      type: 'string',
                      enum: ['and', 'or']
                    },
                    operands: {
                      type: 'array',
                      items: {
                        '$ref' => '#/definitions/operators/$boolean_expression'
                      },
                      minItems: 2
                    }
                  }
                }
              }
            },
            operands: {
              '$one' => {
                oneOf: [
                  { '$ref' => '#/definitions/operands/literal' },
                  { '$ref' => '#/definitions/operands/reference' },
                  { '$ref' => '#/definitions/operands/property' },
                  { '$ref' => '#/definitions/operators/arithmetic/$one' }
                ]
              },
              literal: {
                type: 'object',
                required: ['type', 'value'],
                properties: {
                  type: {
                    type: 'string',
                    enum: ['literal']
                  },
                  value: {
                    type: [
                      'integer',
                      'string',
                      'boolean'
                    ]
                  }
                }
              },
              reference: {
                type: 'object',
                required: ['type', 'uid'],
                properties: {
                  type: {
                    type: 'string',
                    enum: ['reference']
                  },
                  uid: {
                    type: 'string'
                  }
                }
              },
              property: {
                type: 'object',
                required: ['type', 'key', 'cast', 'object'],
                properties: {
                  type: {
                    type: 'string',
                    enum: ['property']
                  },
                  key: {
                    type: 'string'
                  },
                  cast: {
                    type: 'string',
                    enum: ['numeric', 'text']
                  },
                  object: {
                    oneOf: [
                      {
                        type: 'string',
                        enum: ['self']
                      },
                      {
                        '$ref' => '#/definitions/operands/reference'
                      }
                    ]
                  }
                }
              }
            }
          },
          type: 'object',
          properties: {
            condition: {
              '$ref' => '#/definitions/operators/$boolean_expression'
            }
          }
        }
      end
    end
  end
end
