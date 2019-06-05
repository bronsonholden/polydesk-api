FactoryBot.define do
  factory :form do
    name { 'Test form' }
    schema {
      {
        type: 'object',
        properties: {
          name: {
            type: 'string' },
          email: {
            type: 'string' } }
      }
    }
  end
end
