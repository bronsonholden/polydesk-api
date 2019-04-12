PaperTrail.serializer = PaperTrail::Serializers::JSON

PaperTrail.config.has_paper_trail_defaults = {
  on: %i[create update]
}

PaperTrail::Version.class_eval do
  def changed_object
    @changed_object ||= JSON.parse(self.object, object_class: OpenStruct)
  end
end
