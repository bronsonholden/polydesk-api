FactoryBot.define do
  factory :document do
    content { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf')) }
    name { 'RSpec Document' }
  end

  factory :subdocument, class: Document do
    association :folder, factory: :folder, name: 'RSpec Subdocument Folder'
    content { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf')) }
    name { 'RSpec Subdocument' }
  end
end
