# encoding: utf-8

class DocumentUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{Apartment::Tenant.current}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def fog_public
    false
  end

  def fog_authenticated_url_expiration
    5.minutes
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "#{model.versions.size}.#{file.extension}"
  # end

  def filename
    # For some reason, using randomly generated tokens for file names with
    # any sort of file storage doesn't properly create new uploaders/files
    # when an update occurs. Since we'll only use file storage in test runs,
    # we can stpulate that updated files will have different names so we
    # retain previous versions.
    if Rails.env == 'test' # TODO: Also check that we're using file storage
      original_filename if original_filename.present?
    else
      "#{secure_token}.#{file.extension}" if original_filename.present?
    end
  end

  protected
    def secure_token(length=64)
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length / 2))
    end
end
