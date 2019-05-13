class DocumentContentBackgroundUploader < ApplicationJob
  queue_as :document_content_promotion

  def perform(data)
    Shrine::Attacher.promote(data)
  end
end
