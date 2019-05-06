module Polydesk
  module JobDispatcher
    def self.get
      return Rails.application.config.polydesk_job_dispatcher || Polydesk::JobDispatcher::Null
    end
  end
end
