class TenantAwareUnderscoredKeyFormatter < JSONAPI::KeyFormatter
  class << self
    def format(key)
      super.underscore.sub(/\Aaccount_user(s)?\z/, 'user\1')
    end
  end
end
