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
              logical: {
                '$one' => {
                  oneOf: [
                    { '$ref' => '#/definitions/operators/logical/and_or' },
                    { '$ref' => '#/definitions/operators/logical/not' }
                  ]
                },
                and_or: {
                  type: 'object',
                  properties: {
                    operator: {
                      type: 'string',
                      enum: ['and', 'or']
                    },
                    operands: {
                      type: 'array',
                      items: {
                        '$ref' => '#/definitions/operators/$boolean_expression'
                      }
                    }
                  }
                },
                not: {
                  type: 'object',
                  properties: {
                    operator: {
                      type: 'string',
                      enum: ['not']
                    },
                    operand: {
                      '$ref' => '#/definitions/operands/conditionals/$one'
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
                  { '$ref' => '#/definitions/operands/property' }
                ]
              },
              literal: {
                type: 'object',
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
                properties: {
                  type: {
                    type: 'string',
                    enum: ['property']
                  },
                  key: {
                    type: 'string'
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
