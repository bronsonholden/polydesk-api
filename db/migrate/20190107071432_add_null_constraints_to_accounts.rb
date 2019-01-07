class AddNullConstraintsToAccounts < ActiveRecord::Migration[5.2]
  def change
    change_column_null :accounts, :identifier, false
    change_column_null :accounts, :name, false
  end
end
