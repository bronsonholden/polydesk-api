CarrierWave.configure do |config|
  if Rails.env.test?
    config.storage = :file
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

  config.remove_previously_stored_files_after_update = false
end
