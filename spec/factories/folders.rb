FactoryBot.define do
  factory :folder do
    name { 'RSpec Folder' }
  end

  factory :subfolder, class: Folder do
    association :parent, factory: :folder
    name { 'RSPec Subfolder' }
  end
end
