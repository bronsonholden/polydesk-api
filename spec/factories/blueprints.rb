FactoryBot.define do
  factory :blueprint do
    name { 'Test Blueprint' }
    namespace { 'blueprint' }
    # /prefabs?scope[employees]=prefab
    # /prefabs?scope[<namespace>]=<schema key for prefab ref>
    schema {
      {
        :$schema => 'https://polydesk.io/blueprint-schema.json',
        type: 'object',
        properties: {
          string: {
            type: 'string'
          },
          prefab: {
            type: 'string',
            prefab: { # Prefab schema can be passed to POST /prefabs/query to get list of prefabs that match this schema
              namespace: 'employees',
              condition: {
                operation: 'and',
                operands: [
                  {
                    operation: 'eq',
                    operands: [
                      {
                        type: 'ref_property', # own_property
                        key: 'string'
                      },
                      {
                        type: 'literal',
                        value: 'John'
                      }
                    ]
                  },
                  {
                    key: 'name.last',
                    operation: 'in',
                    operands: [
                      type: 'literal',
                      value: ['Doe', 'Deer', 'Smith']
                    ]
                  }
                ]
              }
            }
          }
        }
      }
    }
    # Sample data
    # {
    #   string: "A String",
    #   prefab: "employees/1"
    # }
    # view {
    #   {
    #     rows: [
    #       {
    #         columns: [
    #           {
    #             key: 'string',
    #             type: 'input'
    #           }
    #         ]
    #       },
    #       {
    #         columns: [
    #           {
    #             key: 'prefab',
    #             type: 'prefab'
    #           }
    #         ]
    #       }
    #     ]
    #   }
    # }
  end
end
