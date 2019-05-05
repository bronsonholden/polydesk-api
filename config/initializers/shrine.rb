require 'shrine'
require 'shrine/storage/file_system'
require 'shrine/storage/s3'

if Rails.env.test?
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
    store: Shrine::Storage::FileSystem.new('public', prefix: 'uploads')
  }
else
  aws = Rails.application.credentials.dig(Rails.env.to_sym, :aws)
  s3 = {
    access_key_id: aws[:access_key_id],
    secret_access_key: aws[:secret_access_key],
    bucket: aws[:bucket],
    region: aws[:region]
  }
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
    store: Shrine::Storage::S3.new(**s3)
  }
end

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :determine_mime_type
