ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

# For creating models with CarrierWave attachments
class StringFileIO < StringIO
  def initialize(stream)
    super(stream)
  end

  def original_filename
    'stringio.txt'
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup do
    @account = Account.create(name: 'Test Account', identifier: 'test')
  end
end
