class DocumentSerializer
  include FastJsonapi::ObjectSerializer

  attribute :name do |doc|
    File.basename(doc.content.path)
  end

  # TODO: Serializing content_type slows the request WAY DOWN. Need to cache
  # content type as an attribute/column on document creation and whenever
  # the content is updated with a new version.
  attribute :content_type do |doc|
    doc.content.content_type
  end

  has_one :folder, lazy_load_data: true, links: {
    related: -> (document) {
      document.related_folder_url
    }
  }
end
