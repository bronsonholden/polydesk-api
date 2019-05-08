class FolderContentSerializer
  def initialize(content, options)
    if !content.respond_to?(:map)
      content = [content]
    end

    @data = content.map { |item|
      if item.instance_of?(Document)
        DocumentSerializer.new(item).serializable_hash[:data]
      elsif item.instance_of?(Folder)
        FolderSerializer.new(item).serializable_hash[:data]
      end
    }
    @pagination = options
  end

  def serialized_json
    {
      data: @data
    }.merge(@pagination).to_json
  end
end
