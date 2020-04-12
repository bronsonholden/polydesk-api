class RemoveFormsAndFormSubmissions < ActiveRecord::Migration[5.2]
  def change
    drop_table :form_submission_transitions
    drop_table :form_submissions
    drop_table :forms
  end
end
