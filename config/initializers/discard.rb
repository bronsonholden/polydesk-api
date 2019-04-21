module Discard
  module Model
    def discard
      if self.has_attribute?(:unique_enforcer)
        update(unique_enforcer: nil, discarded_at: Time.current)
      else
        update(discarded_at: Time.current)
      end
    end

    def undiscard
      if self.has_attribute?(:unique_enforcer)
        update(unique_enforcer: 0, discarded_at: nil)
      else
        update(discarded_at: nil)
      end
    end

    def discard!
      if self.has_attribute?(:unique_enforcer)
        update!(unique_enforcer: nil, discarded_at: Time.current)
      else
        update!(discarded_at: Time.current)
      end
    end

    def undiscard!
      if self.has_attribute?(:unique_enforcer)
        update!(unique_enforcer: 0, discarded_at: nil)
      else
        update!(discarded_at: nil)
      end
    end
  end
end
