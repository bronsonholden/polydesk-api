class NullStorage
  attr_reader :uploader

  def initialize(uploader)
    @uploader = uploader
  end

  def identifier
    uploader.filename
  end

  def store!(_file)
    NullFile.new
  end

  def retrieve!(_identifier)
    NullFile.new
  end

  class NullFile
    def delete
    end

    def content_type
      'txt'
    end

    def size
      7
    end

    def read
      return 'Nothing'
    end

    def exists?
      true
    end
  end
end

CarrierWave.configure do |config|
  if Rails.env.test?
    config.storage NullStorage
  end

  if Rails.env.development? || Rails.env.production?
    config.storage = :fog
    config.fog_directory = Rails.application.credentials[Rails.env.to_sym][:aws][:bucket]
    config.fog_public = false

    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Rails.application.credentials[Rails.env.to_sym][:aws][:access_key_id],
      aws_secret_access_key: Rails.application.credentials[Rails.env.to_sym][:aws][:secret_access_key],
      region: Rails.application.credentials[Rails.env.to_sym][:aws][:region]
    }
  end
end
