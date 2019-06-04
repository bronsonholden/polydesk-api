require 'rails_helper'

describe FormSubmission do
  describe 'basic submission' do
    let!(:form) { create :form }
    let!(:data) {
      {
        name: 'John Doe',
        chores: ['Dishes', 'Laundry']
      }
    }
    it 'creates form submission' do
      expect {
        FormSubmission.create!(form: form, submitter: User.last, data: data)
      }.not_to raise_error
    end
  end
end
