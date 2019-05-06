class DocumentContentBackgroundUploader
  @queue = :document_content_promotion

  def self.perform(data)
    tenant = data['tenant']
    Apartment::Tenant.switch(tenant) do
      Shrine::Attacher.promote(data)
    end
  end
end
