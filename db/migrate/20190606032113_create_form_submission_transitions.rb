class CreateFormSubmissionTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :form_submission_transitions do |t|
      t.string :to_state, null: false
      t.json :metadata, default: {}
      t.integer :sort_key, null: false
      t.integer :form_submission_id, null: false
      t.boolean :most_recent, null: false

      t.datetime :created_at, null: false
    end

    # Foreign keys are optional, but highly recommended
    add_foreign_key :form_submission_transitions, :form_submissions

    add_index(:form_submission_transitions,
              [:form_submission_id, :sort_key],
              unique: true,
              name: "index_form_submission_transitions_parent_sort")
    add_index(:form_submission_transitions,
              [:form_submission_id, :most_recent],
              unique: true,
              where: 'most_recent',
              name: "index_form_submission_transitions_parent_most_recent")
  end
end
