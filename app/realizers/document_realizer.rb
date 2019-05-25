class DocumentRealizer
  include JSONAPI::Realizer::Resource
  type :documents, class_name: 'Document', adapter: :active_record
  has_one :folder, class_name: 'FolderRealizer'
  has :name
end
