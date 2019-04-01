class SetNameOnExistingDocuments < ActiveRecord::Migration[5.2]
  def change
    documents = Document.all
    documents.each do |document|
      document.name = File.basename(document.content.path)
      document.save
    end
  end
end
