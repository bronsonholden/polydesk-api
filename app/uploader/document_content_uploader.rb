class DocumentContentUploader < Shrine
  plugin :pretty_location
  plugin :keep_files, replaced: true

  def generate_location(io, context)
    [Apartment::Tenant.current, super].join('/')
  end
end
