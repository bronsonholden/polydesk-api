require 'csv'

module JSONAPI
  module Realizer
    class Adapter
      module ActiveRecordNoFilteringAdapter
        include ActiveRecord
        def filtering(scope, filters)
          scope
        end
      end
    end
  end
end

JSONAPI::Realizer.configuration do |config|
  config.adapter_mappings = {
    active_record_no_filtering: JSONAPI::Realizer::Adapter::ActiveRecordNoFilteringAdapter
  }
end

module JSONAPI::Realizer::Adapter::ActiveRecord
  def paginate(scope, per, offset)
    scope.page(offset.to_i + 1).per(per)
  end

  alias_method :old_filtering, :filtering

  # filter[<col>]=<op>:<val>
  # ops: gt, ge, lt, le, eq, in, like
  # cols: attribute or for FormSubmissions, data.name.first, etc.
  def filtering(scope, filters)
    old_filtering(scope, filters)
  end
end
