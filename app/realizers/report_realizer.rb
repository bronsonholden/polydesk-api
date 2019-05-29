class ReportRealizer
  include JSONAPI::Realizer::Resource
  type :reports, class_name: 'Report', adapter: :active_record
  has :name
end
