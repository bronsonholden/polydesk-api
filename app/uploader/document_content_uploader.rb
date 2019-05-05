class DocumentContentUploader < Shrine
  plugin :pretty_location
  plugin :keep_files, replaced: true
  plugin :backgrounding

  def generate_location(io, context)
    [Apartment::Tenant.current, super].join('/')
  end

  Attacher.promote { |data|
    data[:tenant] = Apartment::Tenant.current
    Resque.enqueue(DocumentContentBackgroundUploader, data)
  }
end
