FactoryBot.define do
  factory :data_control do
    key { 'key' }
    value { 'value' }
    operator { 'eq' }
    namespace { 'namespace' }
    mode { 1 }
    association :group, factory: :group
  end
end
