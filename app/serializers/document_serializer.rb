class DocumentSerializer
  include FastJsonapi::ObjectSerializer

  attribute :name do |doc|
    File.basename(doc.content.path)
  end

  has_one :folder, if: Proc.new { |document|
    !document.folder.nil?
  }
end
