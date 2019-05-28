require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) do
    # Database cleanup
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
    # Tenant cleanup
    Apartment::Tenant.drop('rspec') rescue nil
    user = User.create(first_name: 'RSpec', last_name: 'User', email: 'rspec@Polydesk.io', password: 'password')
    user.confirm
    # Account creation
    account = Account.create(name: 'RSpec Account', identifier: 'rspec')
    account_user = AccountUser.create(account: account, user: user, role: 'user')
    Apartment::Tenant.create('rspec')
  end

  config.before(:each) do
    DatabaseCleaner.start
    Apartment::Tenant.switch! 'rspec'
  end

  config.after(:each) do
    Apartment::Tenant.switch!
    Apartment.tenant_names.each do |tenant|
      Apartment::Tenant.drop(tenant) if tenant != 'rspec'
    end
    DatabaseCleaner.clean
  end

  config.include SessionHelper, :type => :request
  config.include ResponseHelper, :type => :request
end
