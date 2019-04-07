RSpec::Matchers.define :be_array_of do |schema|
  match do |json|
    data_schema_path = "#{Dir.pwd}/spec/support/schemas/data.json"
    model_schema_path = "#{Dir.pwd}/spec/support/schemas/models/#{schema}.json"
    JSON::Validator.validate!(data_schema_path, json)
    json['data'].each do |item|
      JSON::Validator.validate!(model_schema_path, item)
    end
  end
end

RSpec::Matchers.define :be_a do |schema|
  match do |json|
    schema_path = "#{Dir.pwd}/spec/support/schemas/models/#{schema}.json"
    JSON::Validator.validate!(schema_path, json)
  end
end

RSpec::Matchers.alias_matcher :be_an, :be_a

RSpec::Matchers.define :be_paginated do
  match do |json|
    [ 'links', 'pages_meta' ].each do |schema|
      schema_path = "#{Dir.pwd}/spec/support/schemas/#{schema}.json"
      JSON::Validator.validate!(schema_path, json)
    end
  end
end

RSpec::Matchers.define :have_errors do
  match do |json|
    schema_path = "#{Dir.pwd}/spec/support/schemas/error.json"
    JSON::Validator.validate!(schema_path, json)
  end
end
