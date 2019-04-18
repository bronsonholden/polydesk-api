# TODO: Possible that not all objects that ard discardable will have a
# unique enforcer column. Perhaps create a second mixin?
module Discard
  module Model
    def discard
      update(unique_enforcer: nil, discarded_at: Time.current)
    end

    def undiscard
      update(unique_enforcer: 0, discarded_at: nil)
    end

    def discard!
      update!(unique_enforcer: nil, discarded_at: Time.current)
    end

    def undiscard!
      update!(unique_enforcer: 0, discarded_at: nil)
    end
  end
end
