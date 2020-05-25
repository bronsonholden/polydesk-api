class SetDefaultLayoutOnExistingForms < ActiveRecord::Migration[5.2]
  def change
    forms = [] # Form.all
    forms.each do |form|
      form.layout ||= {}
      form.save
    end
  end
end
