class VersionSerializer
  include Rails.application.routes.url_helpers

  def initialize(versions)
    if !versions.respond_to?(:each)
      versions = [ versions ]
    end

    @versions = versions.select { |v| v.event == 'update' }.map { |version|
      serializer = (version.item_type + 'Serializer').classify.constantize
      model = version.item_type.classify.constantize
      object_type = version.item_type.underscore
      object = model.new(JSON.parse(version.object))
      options = { object_id: object.id }
      serialized = serializer.new(object, options).serializable_hash
      attributes = serialized[:data][:attributes]
      data = {
        id: version.id,
        type: 'version',
        attributes: attributes,
        links: { self: version_url(id: object.id,
                                   identifier: Apartment::Tenant.current,
                                   model: object_type,
                                   version: version.id) },
        meta: { object_id: object.id, object_type: object_type }
      }
      data
    }

    @versions = @versions.first if @versions.size == 1
  end

  def serialized_json
    { data: @versions }.to_json
  end
end
