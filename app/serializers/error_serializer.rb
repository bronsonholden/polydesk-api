class ErrorSerializer
  def initialize(errors)
    return if errors.nil?
    @json = {}
    @hash = errors.to_hash.map do |k, v|
      v.map do |msg|
        { id: k, title: "#{k} #{msg}" }
      end
    end
    @json[:errors] = @hash.flatten
  end

  def serialized_json
    @json
  end
end
