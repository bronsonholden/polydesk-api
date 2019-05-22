class TenantAwareDasherizedKeyFormatter < JSONAPI::KeyFormatter
  class << self
    def format(key)
      super.underscore.dasherize.sub(/\Aaccount\-user(s)?\z/, 'user\1')
    end
  end
end
