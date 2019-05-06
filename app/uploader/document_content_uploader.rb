class DocumentContentUploader < Shrine
  plugin :pretty_location
  plugin :keep_files, replaced: true

  def generate_location(io, context)
    [Apartment::Tenant.current, super].join('/')
  end

  Attacher.promote { |data|
    # Store tenant so it can be activated before file is promoted to storage
    data[:tenant] = Apartment::Tenant.current
    dispatcher = Polydesk::JobDispatcher.get
    dispatcher.new.dispatch(DocumentContentBackgroundUploader, data)
  }
end
