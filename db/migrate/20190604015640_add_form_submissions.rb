class AddFormSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :form_submissions do |t|
      t.bigint :submitter_id
      t.jsonb :data, null: false
      t.jsonb :flat_data, null: false
      t.jsonb :schema_snapshot, default: {}
      t.jsonb :layout_snapshot, default: {}
      t.references :form, foreign_key: true, index: true, null: false

      t.timestamps
    end

    add_index :form_submissions, "(flat_data->>'value')", name: 'index_form_submissions_on_flat_data_value'
  end
end
