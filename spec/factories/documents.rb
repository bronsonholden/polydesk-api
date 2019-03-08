FactoryBot.define do
  factory :subdocument, class: Document do
    association :folder, factory: :folder
    content { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/compressed.tracemonkey-pldi-09.pdf')) }
    name { 'RSPec Subfolder' }
  end
end
