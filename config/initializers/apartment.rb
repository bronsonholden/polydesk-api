Apartment.configure do |config|
  config.excluded_models = %w{User}
  # TODO: Add "activated_at" or similar attribute to Accounts, to be set
  # when the root user is confirmed and the account is linked as its default.
  # Use that to get a list of tenants
  config.tenant_names = lambda { User.pluck(:identifier) }
end
