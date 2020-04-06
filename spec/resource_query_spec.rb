require 'rails_helper'

RSpec.describe ResourceQuery do
  # Stub schema and view
  let(:schema) { { type: 'object' } }
  let(:view) { { xs: {} } }

  let!(:employees_blueprint) { create :blueprint, name: 'Employees', namespace: 'employees', schema: schema, view: view }
  let!(:jobs_blueprint) { create :blueprint, name: 'Jobs', namespace: 'jobs', schema: schema, view: view }

  let(:employee_data) {
    {
      name: 'John Doe',
      age: 30
    }
  }

  let(:base_scope) { Blueprint.all }
  let(:query_class) { ResourceQuery }
  let(:query) { query_class.new(payload) }
  let(:applied_scope) { query.apply(base_scope) }

  describe 'generators' do
    let(:payload) {
      {
        "generate" => {
          "#{identifier}" => generator
        }
      }
    }

    describe 'functions' do
      describe 'prop' do
        let(:base_scope) { Blueprint.where(id: employees_blueprint.id) }
        let(:identifier) { 'prop_column' }
        let(:generator) { "prop('name')" }

        it 'applies prop' do
          expect(applied_scope.first.prop_column).to eq('Employees')
        end
      end

      describe 'concat' do
        let(:identifier) { 'concat_column' }
        let(:generator) { "concat(concat('a', 'b'), 1, true)" }

        it 'applies concat' do
          expect(applied_scope.first.concat_column).to eq("ab1true")
        end
      end
    end

    # Test generating columns using only literals
    describe 'literals' do
      describe 'string' do
        let(:identifier) { 'literal_string' }
        let(:generator) { '"literal_string"' }

        it 'generates column' do
          expect(applied_scope.first.literal_string).to eq('literal_string')
        end

        describe 'validation' do
          context 'with malicious SQL' do
            let(:bad_sql) { "'');--" }
            let(:generator) { "\"#{bad_sql}\"" }

            it 'generates column' do
              expect(applied_scope.first.literal_string).to eq(bad_sql)
            end
          end
        end
      end

      describe 'integer' do
        let(:identifier) { 'literal_integer' }
        let(:generator) { '5' }

        it 'generates column' do
          expect(applied_scope.first.literal_integer).to eq(5)
        end
      end

      describe 'float' do
        let(:identifier) { 'literal_float' }
        let(:generator) { '5.2e3' }

        it 'generates column' do
          expect(applied_scope.first.literal_float).to eq(5.2e3)
        end
      end
    end

    describe 'operators' do
      describe '+' do
        let(:identifier) { 'sum' }
        let(:generator) { '1 + 2.5 + 3' }

        it 'generates column' do
          expect(applied_scope.first.sum).to eq(6.5)
        end
      end

      describe '-' do
        let(:identifier) { 'difference' }
        let(:generator) { '0 - 5.2 - 1' }

        it 'generates column' do
          expect(applied_scope.first.difference).to eq(-6.2)
        end
      end

      describe '*' do
        let(:identifier) { 'product' }
        let(:generator) { '2 * 3' }

        it 'generate column' do
          expect(applied_scope.first.product).to eq(6)
        end
      end

      describe '/' do
        let(:identifier) { 'quotient' }
        let(:generator) { '5.0 / 2.0' }

        it 'generate column' do
          expect(applied_scope.first.quotient).to eq(2.5)
        end
      end

      describe '%' do
        let(:identifier) { 'remainder' }

        context 'integers' do
          let(:generator) { '5 % 2' }

          it 'generate column' do
            expect(applied_scope.first.remainder).to eq(1)
          end
        end

        context 'floats' do
          let(:generator) { '5.3 % 2' }

          it 'generates column' do
            expect(applied_scope.first.remainder).to eq(1.3)
          end
        end
      end
    end

    describe 'identifiers' do
      describe 'validation' do
        context 'with restricted characters' do
          let(:identifier) { "';--'" }
          let(:generator) { 'data.id' }

          it 'raises invalid generate identifier error' do
            expect { applied_scope }.to raise_error(Polydesk::Errors::InvalidGeneratedColumnIdentifier)
          end
        end

        context 'starting with number' do
          let(:identifier) { '1e2' }
          let(:generator) { 'data.number' }

          it 'raises invalid generate identifier error' do
            expect { applied_scope }.to raise_error(Polydesk::Errors::InvalidGeneratedColumnIdentifier)
          end
        end

        context 'with restricted identifier name' do
          let(:identifier) { 'namespace' }
          let(:generator) { 'data.namespace' }

          it 'raises restricted generate identifier error' do
            expect { applied_scope }.to raise_error(Polydesk::Errors::RestrictedGeneratedColumnIdentifier)
          end
        end
      end
    end
  end

  describe "filter" do
    let(:payload) {
      {
        "filter" => filter_expression
      }
    }

    context "multiple values" do
      let(:filter_expression) {
        ["prop('name') != 'Employees'", "prop('name') != 'Jobs'"]
      }

      it "returns no matches" do
        expect(applied_scope.size).to eq(0)
      end
    end

    describe "functions" do
      describe 'json' do
        before(:each) do
          create :prefab, blueprint: employees_blueprint, data: { name: 'John Doe', age: 30, gpa: 3.5, employed: false }
          create :prefab, blueprint: employees_blueprint, data: { name: 'Jane Roe', age: 20, gpa: 3.3, employed: true }
        end

        let(:base_scope) { Prefab.all }

        describe 'json_s' do
          let(:filter_expression) { "json_s('data.name') == 'John Doe'" }

          it 'returns match' do
            expect(applied_scope.size).to eq(1)
          end
        end

        describe 'json_i' do
          let(:filter_expression) { "json_i('data.age') > 20" }

          it 'returns match' do
            expect(applied_scope.size).to eq(1)
          end
        end

        describe 'json_f' do
          let(:filter_expression) { "json_f('data.gpa') < 3.5" }

          it 'returns match' do
            expect(applied_scope.size).to eq(1)
          end
        end

        describe 'json_b' do
          let(:filter_expression) { "json_b('data.employed') == false" }

          it 'returns match' do
            expect(applied_scope.size).to eq(1)
          end
        end
      end

      describe "generate" do
        let(:filter_expression) { "generate(concat(prop('name'), prop('namespace'))) == 'Employeesemployees'"}

        it "returns match" do
          jobs_blueprint
          employees_blueprint
          expect(applied_scope.size).to eq(1)
        end

        context "with lookups" do
          let(:filter_expression) { "generate(lookup_s('data.job', 'data.title')) == 'Teacher'"}
          let(:job) { create :prefab, blueprint: jobs_blueprint, data: { title: "Teacher" } }
          let(:employee) { create :prefab, blueprint: employees_blueprint, data: { job: "#{job.namespace}/#{job.tag}" } }
          let(:base_scope) { Prefab.all }
          let(:query_class) { PrefabQuery }

          it "returns match" do
            employee
            expect(applied_scope.size).to eq(1)
          end
        end
      end
    end

    describe "comparators" do
      describe "==" do
        let(:filter_expression) { "prop('name') == 'Employees'" }

        it "returns match" do
          expect(applied_scope.size).to eq(1)
          expect(applied_scope.first.name).to eq('Employees')
        end
      end

      describe "!=" do
        let(:filter_expression) { "prop('name') != 'Employees'" }

        it "does not return match" do
          expect(applied_scope.size).to eq(1)
          expect(applied_scope.first.name).not_to eq('Employees')
        end
      end
    end

    describe "errors" do
      context "invalid prop columnn identifier" do
        let(:filter_expression) { "prop(\"';--\")" }

        it "raises error" do
          expect { applied_scope }.to raise_error(Polydesk::Errors::InvalidPropertyIdentifier)
        end
      end
    end
  end
end
