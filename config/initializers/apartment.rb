Apartment.configure do |config|
  config.excluded_models = %w{Account User AccountUser}
  config.tenant_names = lambda { Account.pluck :identifier }
end
