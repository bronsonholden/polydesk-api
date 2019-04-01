class DocumentSerializer
  include FastJsonapi::ObjectSerializer

  attributes :content_type, :file_size, :created_at, :updated_at, :name

  has_one :folder, lazy_load_data: true, links: {
    related: -> (document) {
      document.related_folder_url
    }
  }

  link :self, -> (document) {
    document.url
  }
end
