class DocumentSerializer
  include FastJsonapi::ObjectSerializer

  attributes :content_type, :file_size

  attribute :name do |doc|
    File.basename(doc.content.path)
  end

  has_one :folder, lazy_load_data: true, links: {
    related: -> (document) {
      document.related_folder_url
    }
  }
end
