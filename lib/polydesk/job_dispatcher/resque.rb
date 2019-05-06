module Polydesk
  module JobDispatcher
    class Resque
      def dispatch(worker, data)
        ::Resque.enqueue(worker, data)
      end
    end
  end
end
