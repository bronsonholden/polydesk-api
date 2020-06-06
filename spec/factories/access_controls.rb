FactoryBot.define do
  factory :access_control do
    namespace { 'namespace' }
    mode { 1 }
    association :group, factory: :group
  end
end
