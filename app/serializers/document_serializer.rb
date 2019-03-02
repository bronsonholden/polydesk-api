class DocumentSerializer
  include FastJsonapi::ObjectSerializer
  attribute :name do |doc|
    File.basename(doc.content.path)
  end
end
