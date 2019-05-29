class VersionSerializer < ApplicationSerializer
  def type
    object.reify.class.name.underscore if !object.reify.nil?
  end

  def id
    object.reify.id.to_s
  end

  def meta
    { version_id: object.id }
  end

  def self_link
    "#{super}/versions/#{object.id}"
  end

  def relationship_self_link(attribute_name)
    nil
  end

  def relationship_related_link(attribute_name)
    nil
  end
end

module PaperTrail
  VersionSerializer = ::VersionSerializer
end
