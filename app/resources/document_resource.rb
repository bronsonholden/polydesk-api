# class DocumentSerializer
#   include FastJsonapi::ObjectSerializer
#
#   attributes :content_type, :file_size, :created_at, :updated_at, :name, :discarded_at
#
#   attribute :discarded_at do |document|
#     document.discarded_at || ''
#   end
#
#   has_one :folder, lazy_load_data: true, links: {
#     related: -> (document) {
#       document.related_folder_url
#     }
#   }
#
#   link :self, -> (document) {
#     document.url
#   }
# end

class DocumentResource < DiscardableResource
  attributes :content_type, :file_size, :created_at, :updated_at, :name, :discarded_at

  has_one :folder
end
