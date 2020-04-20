RSpec::Matchers.define :have_changed_attributes do
  match do |record|
    Apartment::Tenant.switch('rspec') do
      before = record.attributes.except('updated_at')
      after = record.reload.attributes.except('updated_at')
      return before != after
    end
  end
end
