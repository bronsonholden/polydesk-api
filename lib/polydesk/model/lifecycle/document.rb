module Polydesk
  module Model
    module Lifecycle
      module Document
        extend ActiveSupport::Concern

        included do
          before_validation :default_folder, :set_document_name, :enumerate_name
          before_save :save_content_attributes, :within_storage_limit

          after_save do
            if self.skip_background_upload
              self.skip_background_upload = false
              self.content_attacher.promote
              self.save
            end
          end

          # Destroy this record's associated versions
          before_destroy do
            self.versions.destroy_all
          end
        end
      end
    end
  end
end
