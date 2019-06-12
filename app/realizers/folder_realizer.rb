class FolderRealizer
  include JSONAPI::Realizer::Resource
  type :folders, class_name: 'Folder', adapter: :active_record
  has_one :folder, class_name: 'FolderRealizer'
  has_many :folders, class_name: 'FolderRealizer'
  has_many :documents, class_name: 'DocumentRealizer'
  has :name
end
