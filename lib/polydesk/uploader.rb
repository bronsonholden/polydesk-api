module Polydesk
  module Uploader
    extend ActiveSupport::Concern

    module ClassMethods
      def upload_in_background(column)
        attr_accessor :"upload_#{column}_now"

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def enqueue_upload_#{column}
            ::Resque.enqueue(BackgroundUploader, self.class.to_s, id, "#{column}", Apartment::Tenant.current)
          end
        RUBY

        mod = Module.new
        include mod

        mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def write_#{column}_identifier
            super and return if upload_#{column}_now
            self.#{column}_tmp = _mounter(:#{column}).cache_name if _mounter(:#{column}).cache_name
          end

          def store_#{column}!
            if upload_#{column}_now
              super
            else
              enqueue_upload_#{column}
            end
          end
        RUBY
      end
    end
  end
end
