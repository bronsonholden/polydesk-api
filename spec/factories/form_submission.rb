FactoryBot.define do
  factory :form_submission do
    association :form, factory: :form
    submitter { User.first }
  end
end
