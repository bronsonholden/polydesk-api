class AddDiscardedAtToFormSubmissions < ActiveRecord::Migration[5.2]
  def change
    def change
      add_column :form_submissions, :discarded_at, :datetime
      add_index :form_submissions, :discarded_at
    end
  end
end
