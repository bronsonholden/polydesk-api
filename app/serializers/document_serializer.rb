class DocumentSerializer
  include FastJsonapi::ObjectSerializer

  attribute :name do |doc|
    File.basename(doc.content.path)
  end

  attribute :content_type do |doc|
    doc.content.content_type
  end

  has_one :folder, if: Proc.new { |document|
    !document.folder.nil?
  }
end
