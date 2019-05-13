module Polydesk
  module JobDispatcher
    class ActiveJob
      def dispatch(worker, data)
        if data[:immediately]
          Apartment::Tenant.switch(data[:tenant]) do
            worker.perform_now(data)
          end
        else
          worker.perform_later(data)
        end
      end
    end
  end
end
