class FolderSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :created_at, :updated_at, :discarded_at, :path

  attribute :discarded_at do |folder|
    folder.discarded_at || ''
  end

  attribute :parent_folder_id do |folder|
    if folder.parent_id == 0
      ''
    else
      folder.parent_id.to_s
    end
  end

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

  link :self, -> (folder) {
    folder.url
  }
end
