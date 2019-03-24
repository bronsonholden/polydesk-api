class FolderSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name

  has_many :documents, lazy_load_data: true, links: {
    related: -> (folder) {
      folder.related_documents_url
    }
  }

  has_many :folders, lazy_load_data: true, links: {
    related: -> (folder) {
      folder.related_folders_url
    }
  }
end
