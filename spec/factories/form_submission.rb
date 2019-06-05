FactoryBot.define do
  factory :form_submission do
    association :form, factory: :form
    submitter { User.first }
    data {
      {
        name: 'John Doe',
        email: 'john@email.com'
      }
    }
  end
end
