class UpdateAllDocumentsContentAttributes < ActiveRecord::Migration[5.2]
  def change
    @documents = Document.all
    @documents.each do |document|
      document.save
    end
  end
end
