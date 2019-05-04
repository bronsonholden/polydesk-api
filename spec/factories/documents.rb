FactoryBot.define do
  factory :document do
    upload_content_now { true }
    content { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf')) }
    name { 'RSpec Document' }
  end

  factory :document_upload_later, class: Document do
    upload_content_now { false }
    content { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf')) }
    name { 'RSpec Document' }
  end

  factory :subdocument, parent: :document do
    association :folder, factory: :folder, name: 'RSpec Subdocument Folder'
  end

  factory :versioned_document, parent: :document do
    content { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/fox.txt')) }
    name { 'RSpec Fox' }
    after(:create) do |document, evaluator|
      document.content = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/dog.txt'))
      document.name = 'RSpec Dog'
      document.save!
    end
  end

  factory :discarded_document, parent: :document do
    before(:create) do |document, evaluator|
      document.discard!
    end
  end
end
