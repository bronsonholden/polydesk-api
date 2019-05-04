class BackgroundUploader
  @queue = :carrierwave

  def self.perform(klass, id, column, tenant)
    Apartment::Tenant.switch(tenant) do
      record = klass.constantize.find(id)
      get_directories(record)
      record.send :"upload_#{column}_now", true
      record.send :"#{column}_tmp", nil
      File.open(cache_path) { |file|
        record.send :"#{colummn}", file
      }
      if record.save!
        FileUtils.rm_r(tmp_directory)
      end
    end
  end

  def get_directories(record)
    asset, asset_tmp = record.send(:"#{column}"), record.send(:"#{column}_tmp")
    cache_directory = File.expand_path(asset.cache_dir, asset.root)
    @cache_path = File.join(cache_directory, asset_tmp)
    @tmp_directory = File.join(cache_directory, asset_tmp.split("/").first)
  end
end
