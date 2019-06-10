class AddDiscardedAtToForms < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :discarded_at, :datetime
    add_index :forms, :discarded_at
  end
end
