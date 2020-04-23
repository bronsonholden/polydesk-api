require 'rails_helper'

RSpec.describe ResourceQuery do
  # Stub schema and view
  let(:schema) { { type: 'object' } }
  let(:view) { { xs: {} } }

  let!(:employees_blueprint) { create :blueprint, name: 'Employees', namespace: 'employees', schema: schema, view: view }
  let!(:jobs_blueprint) { create :blueprint, name: 'Jobs', namespace: 'jobs', schema: schema, view: view }

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

    describe 'constants' do
      describe 'pi' do
        let(:identifier) { 'pi_column' }
        let(:generator) { 'PI' }

        it 'returns value' do
          expect(applied_scope.first.pi_column).to be_within(0.00001).of(Math::PI)
        end
      end

      describe 'e' do
        let(:identifier) { 'e_column' }
        let(:generator) { 'E' }

        it 'returns value' do
          expect(applied_scope.first.e_column).to be_within(0.00001).of(Math::E)
        end
      end
    end

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

      describe 'coalesce' do
        let(:base_scope) { Prefab.all }
        let(:identifier) { 'coalesce_column' }
        let(:generator) { "coalesce(prop('data.primary'), prop('data.secondary'))" }
        let(:prefab) { create :prefab, blueprint: employees_blueprint, data: data }

        context 'valid primary' do
          let(:data) {
            {
              primary: 'primary'
            }
          }

          it 'returns value' do
            prefab
            expect(applied_scope.first.coalesce_column).to eq('primary')
          end
        end

        context 'invalid primary' do
          let(:data) {
            {
              secondary: 'secondary'
            }
          }

          it 'returns value' do
            prefab
            expect(applied_scope.first.coalesce_column).to eq('secondary')
          end
        end
      end

      describe 'lower' do
        let(:identifier) { 'lower_column' }
        let(:generator) { 'lower("STRING")' }

        it 'returns value' do
          expect(applied_scope.first.lower_column).to eq('string')
        end
      end

      describe 'upper' do
        let(:identifier) { 'upper_column' }
        let(:generator) { 'upper("string")' }

        it 'returns value' do
          expect(applied_scope.first.upper_column).to eq('STRING')
        end
      end

      describe 'sqrt' do
        let(:base_scope) { Prefab.all }
        let(:identifier) { 'sqrt_column' }
        let(:generator) { 'sqrt(prop("data.number"))' }
        let(:prefab) { create :prefab, blueprint: employees_blueprint, data: { number: 100 } }

        it 'returns value' do
          prefab
          expect(applied_scope.first.sqrt_column).to eq(10)
        end
      end

      describe 'pow' do
        let(:base_scope) { Prefab.all }
        let(:identifier) { 'sqrt_column' }
        let(:generator) { 'pow(prop("data.number"), 2)' }
        let(:prefab) { create :prefab, blueprint: employees_blueprint, data: { number: 10 } }

        it 'returns value' do
          prefab
          expect(applied_scope.first.sqrt_column).to eq(100)
        end
      end

      describe 'log' do
        let(:identifier) { 'log_column' }
        let(:generator) { 'log(100)' }

        it 'returns value' do
          expect(applied_scope.first.log_column).to eq(2)
        end

        context 'with custom base' do
          let(:generator) { 'log(64, 2)' }

          it 'returns value' do
            expect(applied_scope.first.log_column).to eq(6)
          end
        end
      end

      describe 'ln' do
        let(:identifier) { 'ln_column' }
        let(:generator) { 'ln(2.718)' }

        it 'returns value' do
          expect(applied_scope.first.ln_column).to be_within(0.001).of(1)
        end
      end

      describe 'exp' do
        let(:identifier) { 'exp_column' }
        let(:generator) { 'exp(1)' }

        it 'returns value' do
          expect(applied_scope.first.exp_column).to be_within(0.001).of(Math::E)
        end
      end

      describe 'abs' do
        let(:identifier) { 'abs_column' }
        let(:generator) { 'abs(-10)' }

        it 'returns value' do
          expect(applied_scope.first.abs_column).to eq(10)
        end
      end

      describe 'floor' do
        let(:identifier) { 'floor_column' }
        let(:generator) { 'floor(5.2)' }

        it 'returns value' do
          expect(applied_scope.first.floor_column).to eq(5)
        end
      end

      describe 'ceil' do
        let(:identifier) { 'ceil_column' }
        let(:generator) { 'ceil(5.2)' }

        it 'returns value' do
          expect(applied_scope.first.ceil_column).to eq(6)
        end
      end

      describe 'round' do
        let(:identifier) { 'round_column' }
        let(:generator) { 'round(4.5)' }

        it 'returns value' do
          expect(applied_scope.first.round_column).to eq(5)
        end

        context 'remainder less than 0.5' do
          let(:generator) { 'round(4.4)' }

          it 'returns value' do
            expect(applied_scope.first.round_column).to eq(4)
          end
        end

        context 'remainder greater than 0.5' do
          let(:generator) { 'round(4.6)' }

          it 'returns value' do
            expect(applied_scope.first.round_column).to eq(5)
          end
        end
      end

      describe 'current_date' do
        let(:identifier) { 'current_date_column' }
        let(:generator) { "current_date('UTC')" }

        it 'returns value' do
          expect(applied_scope.first.current_date_column).to eq(Date.today.in_time_zone('UTC'))
        end

        context 'tz as property' do
          # Not a representative use case, but qualifies
          let(:blueprint) { create :blueprint, name: Time.now.zone, namespace: Time.now.zone.downcase }
          let(:base_scope) { Blueprint.where(id: blueprint.id) }
          let(:generator) { 'current_date(prop("name"))' }

          it 'returns value' do
            expect(applied_scope.first.current_date_column).to eq(Date.today)
          end
        end
      end

      describe 'current_timestamp' do
        let(:identifier) { 'current_timestamp_column' }
        let(:generator) { "current_timestamp()" }

        it 'returns value' do
          expect(applied_scope.first.current_timestamp_column).to be_within(1.second).of(Time.now)
        end
      end

      describe 'interval' do
        let(:identifier) { 'interval_column' }
        let(:generator) { "current_timestamp() + interval(#{amount}, '#{unit}')" }
        let(:base_time) { Time.now }
        let(:expected_time) { base_time + amount.send(unit.to_s) }

        shared_examples 'interval_success' do
          it 'returns value' do
            expect(applied_scope.first.interval_column).to be_within(1.second).of(expected_time)
          end
        end

        describe 'years' do
          let(:amount) { 5 }

          context 'years' do
            let(:unit) { 'years' }
            include_examples 'interval_success'
          end

          context 'year' do
            let(:unit) { 'year' }
            include_examples 'interval_success'
          end
        end

        describe 'months' do
          let(:amount) { 5 }

          context 'months' do
            let(:unit) { 'months' }
            include_examples 'interval_success'
          end

          context 'month' do
            let(:unit) { 'month' }
            include_examples 'interval_success'
          end
        end

        describe 'weeks' do
          let(:amount) { 5 }

          context 'weeks' do
            let(:unit) { 'weeks' }
            include_examples 'interval_success'
          end

          context 'week' do
            let(:unit) { 'week' }
            include_examples 'interval_success'
          end
        end

        describe 'days' do
          let(:amount) { 1 }

          context 'days' do
            let(:unit) { 'days' }
            include_examples 'interval_success'
          end

          context 'day' do
            let(:unit) { 'day' }
            include_examples 'interval_success'
          end
        end

        describe 'hours' do
          let(:amount) { 5 }

          context 'hours' do
            let(:unit) { 'hours' }
            include_examples 'interval_success'
          end

          context 'hour' do
            let(:unit) { 'hour' }
            include_examples 'interval_success'
          end
        end

        describe 'minutes' do
          let(:amount) { 5 }

          context 'minutes' do
            let(:unit) { 'minutes' }
            include_examples 'interval_success'
          end

          context 'minute' do
            let(:unit) { 'minute' }
            include_examples 'interval_success'
          end
        end

        describe 'seconds' do
          let(:amount) { 5 }

          context 'seconds' do
            let(:unit) { 'seconds' }
            include_examples 'interval_success'
          end

          context 'second' do
            let(:unit) { 'second' }
            include_examples 'interval_success'
          end
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

      describe '~' do
        let(:identifier) { 'bitwise_not' }
        let(:generator) { '~2' }

        it 'generates column' do
          expect(applied_scope.first.bitwise_not).to eq(-3)
        end
      end

      describe '&' do
        let(:identifier) { 'bitwise_and' }
        let(:generator) { '2 & 3' }

        it 'generates column' do
          expect(applied_scope.first.bitwise_and).to eq(2)
        end
      end

      describe '|' do
        let(:identifier) { 'bitwise_or' }
        let(:generator) { '2 | 1' }

        it 'generates column' do
          expect(applied_scope.first.bitwise_or).to eq(3)
        end
      end

      describe '>>' do
        let(:identifier) { 'bitwise_rshift' }
        let(:generator) { '2 >> 1' }

        it 'generates column' do
          expect(applied_scope.first.bitwise_rshift).to eq(1)
        end
      end

      describe '<<' do
        let(:identifier) { 'bitwise_lshift' }
        let(:generator) { '2 << 1' }

        it 'generates column' do
          expect(applied_scope.first.bitwise_lshift).to eq(4)
        end
      end

      describe '^' do
        let(:identifier) { 'bitwise_xor' }
        let(:generator) { '3 ^ 1' }

        it 'generates column' do
          expect(applied_scope.first.bitwise_xor).to eq(2)
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

    context 'with invalid expression' do
      let(:filter_expression) {
        "prop('name')"
      }

      it 'raises error' do
        expect { applied_scope }.to raise_error(Polydesk::Errors::InvalidFilterExpression)
      end
    end

    describe "functions" do
      describe 'and' do
        let(:filter_expression) { "prop('name') == 'Employees' && prop('namespace') == 'employees' && prop('id') == #{employees_blueprint.id}" }

        it 'returns match' do
          expect(applied_scope.size).to eq(1)
        end
      end

      describe 'or' do
        let(:filter_expression) { "prop('name') == 'Employees' || prop('name') == 'Jobs' || prop('id') != #{Blueprint.all.size + 1}" }

        it 'returns match' do
          expect(applied_scope.size).to eq(2)
        end
      end

      describe "sub-generate" do
        let(:filter_expression) { "(concat(prop('name'), prop('namespace'))) == 'Employeesemployees'"}

        it "returns match" do
          jobs_blueprint
          employees_blueprint
          expect(applied_scope.size).to eq(1)
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
        let(:filter_expression) { "prop(\"';--\") == ''" }

        it "raises error" do
          expect { applied_scope }.to raise_error(Polydesk::Errors::InvalidPropertyIdentifier)
        end
      end

      context "invalid filter expression" do
        let(:filter_expression) { "prop('name')" }

        it "raises error" do
          expect { applied_scope }.to raise_error(Polydesk::Errors::InvalidFilterExpression)
        end
      end
    end
  end
end
