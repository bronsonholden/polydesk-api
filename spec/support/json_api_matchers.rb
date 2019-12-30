RSpec::Matchers.define :be_array_of do |schema|
  match do |json|
    data_schema_path = "#{Dir.pwd}/spec/support/schemas/data.json"
    model_schema_path = "#{Dir.pwd}/spec/support/schemas/models/#{schema}.json"
    JSON::Validator.validate!(data_schema_path, json, strict: true)
    json['data'].each do |item|
      JSON::Validator.validate!(model_schema_path, item, strict: true)
    end
  end
end

RSpec::Matchers.define :be_a do |schema|
  match do |json|
    schema_path = "#{Dir.pwd}/spec/support/schemas/models/#{schema}.json"
    JSON::Validator.validate!(schema_path, json['data'], strict: true)
  end
end

RSpec::Matchers.alias_matcher :be_an, :be_a

RSpec::Matchers.define :have_errors do
  match do |json|
    schema_path = "#{Dir.pwd}/spec/support/schemas/error.json"
    JSON::Validator.validate!(schema_path, json, strict: true)
  end
end

RSpec::Matchers.define :have_attribute do |hash|
  match do |json|
    attributes = json.fetch('data', {}).fetch('attributes', {})
    hash.each { |k, v|
      if attributes[k.to_s] != v
        return false
      end
    }
    true
  end
end

RSpec::Matchers.define :have_changed_attributes do
  match do |record|
    Apartment::Tenant.switch('rspec') do
      before = record.attributes.except('updated_at')
      after = record.reload.attributes.except('updated_at')
      puts before
      puts after
      return before != after
    end
  end
end
