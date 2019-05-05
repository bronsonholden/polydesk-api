class DocumentContentBackgroundUploader
  @queue = :document_content_promotion

  def self.perform(data)
    Shrine::Attacher.promote(data)
  end
end
