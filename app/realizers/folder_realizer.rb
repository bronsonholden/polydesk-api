class FolderRealizer
  include JSONAPI::Realizer::Resource
  type :folders, class_name: 'Folder', adapter: :active_record
  has_one :parent, class_name: 'FolderRealizer'
  has_many :children, class_name: 'FolderRealizer'
  has_many :documents, class_name: 'DocumentRealizer'
  has :name
end
