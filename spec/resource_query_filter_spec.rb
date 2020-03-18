require 'rails_helper'

RSpec.describe ResourceQueryFilter do
  # Stub schema and view
  let(:schema) { { type: 'object' } }
  let(:view) { { xs: {} } }

  let!(:employees_blueprint) { create :blueprint, name: 'Employees', namespace: 'employees', schema: schema, view: view }
  let!(:jobs_blueprint) { create :blueprint, name: 'Jobs', namespace: 'jobs', schema: schema, view: view }

  let(:payload) {
    {
      "filter" => {
        "name" => "#{filter_expression}"
      }
    }
  }

  let(:base_scope) { Blueprint.all }
  let(:applicator) { ResourceQueryFilter.new(payload) }
  let(:filtered_scope) { applicator.apply(base_scope) }

  describe "comparator functions" do
    describe "eq" do
      let(:filter_expression) { "eq('Employees')" }

      it "returns match" do
        expect(filtered_scope.size).to eq(1)
        expect(filtered_scope.first.name).to eq('Employees')
      end
    end

    describe "neq" do
      let(:filter_expression) { "neq('Employees')" }

      it "does not return match" do
        expect(filtered_scope.size).to eq(1)
        expect(filtered_scope.first.name).not_to eq('Employees')
      end
    end
  end
end
