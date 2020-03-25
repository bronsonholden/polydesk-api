require 'rails_helper'

RSpec.describe ResourceQueryFilter do
  # Stub schema and view
  let(:schema) { { type: 'object' } }
  let(:view) { { xs: {} } }

  let!(:employees_blueprint) { create :blueprint, name: 'Employees', namespace: 'employees', schema: schema, view: view }
  let!(:jobs_blueprint) { create :blueprint, name: 'Jobs', namespace: 'jobs', schema: schema, view: view }

  let(:payload) {
    {
      "filter" => filter_expression
    }
  }

  let(:base_scope) { Blueprint.all }
  let(:applicator) { ResourceQueryFilter.new(payload) }
  let(:filtered_scope) { applicator.apply(base_scope) }

  context "multiple values" do
    let(:filter_expression) {
      ["prop('name') != 'Employees'", "prop('name') != 'Jobs'"]
    }

    it "returns no matches" do
      expect(filtered_scope.size).to eq(0)
    end
  end

  describe "functions" do
    describe "generate" do
      let(:filter_expression) { "generate(concat(prop('name'), prop('namespace'))) == 'Employeesemployees'"}

      it "returns match" do
        expect(filtered_scope.size).to eq(1)
      end

      context "with lookups" do
        let(:filter_expression) { "generate(lookup_s('data.job', 'data.title')) == 'Teacher'"}
        let(:job) { create :prefab, blueprint: jobs_blueprint, data: { title: "Teacher" } }
        let(:employee) { create :prefab, blueprint: employees_blueprint, data: { job: "#{job.namespace}/#{job.tag}" } }
        let(:base_scope) { Prefab.all }

        it "returns match" do
          employee
          expect(filtered_scope.size).to eq(1)
        end
      end
    end
  end

  describe "comparators" do
    describe "==" do
      let(:filter_expression) { "prop('name') == 'Employees'" }

      it "returns match" do
        expect(filtered_scope.size).to eq(1)
        expect(filtered_scope.first.name).to eq('Employees')
      end
    end

    describe "!=" do
      let(:filter_expression) { "prop('name') != 'Employees'" }

      it "does not return match" do
        expect(filtered_scope.size).to eq(1)
        expect(filtered_scope.first.name).not_to eq('Employees')
      end
    end
  end

  describe "errors" do
    context "invalid prop columnn identifier" do
      let(:filter_expression) { "prop(\"';--\")" }

      it "raises error" do
        expect { filtered_scope }.to raise_error(Polydesk::Errors::InvalidPropertyIdentifier)
      end
    end
  end
end
