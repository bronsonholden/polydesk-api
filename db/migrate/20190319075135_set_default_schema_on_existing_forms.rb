class SetDefaultSchemaOnExistingForms < ActiveRecord::Migration[5.2]
  def change
    forms = Form.all
    forms.each do |form|
      form.schema ||= {}
      form.save
    end
  end
end
