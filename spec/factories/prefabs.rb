FactoryBot.define do
  factory :prefab do
    namespace { 'prefab' }
    association :blueprint, factory: :blueprint
    schema {
      {
        type: 'object'
      }
    }
    view {
      {
        stub: true
      }
    }
    data {
      {
        stub: true
      }
    }
  end
end
