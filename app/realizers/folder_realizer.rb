class FolderRealizer
  include JSONAPI::Realizer::Resource
  type :folders, class_name: 'Folder', adapter: :active_record
  has_one :parent, class_name: 'Folder'
  has_many :children, class_name: 'Folder'
  has_many :documents, class_name: 'Document'
  has :name
end
