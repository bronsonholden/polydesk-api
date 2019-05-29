class FormRealizer
  include JSONAPI::Realizer::Resource
  type :forms, class_name: 'Form', adapter: :active_record
  has :name
  has :schema
  has :layout
end
