require 'rails_helper'

RSpec.describe PrefabQueryGenerate do
  # Base data to create our Prefabs with
  let(:data) {
    {
      prefab: '',
      string: 'string',
      number: 0,
      boolean: true
    }
  }

  # Blueprint & Prefab objects
  let(:blueprint) { create :blueprint, schema: { type: 'object' }, namespace: 'prefabs' }
  let(:prefab) { create :prefab, data: data, blueprint: blueprint }

  # our generator expressions
  let(:generate) {
    {
      "#{identifier}" => "#{generator}"
    }
  }

  # Our generator payload and object
  let(:payload) { { 'generate' => generate } }
  let(:processor) { PrefabQuery.new(payload) }

  # Scope with generated columns applied
  let(:generated_scope) { processor.apply(scope) }

  # Base scope to use when generating columns
  let(:scope) { Prefab.all }

  describe 'generators' do
    before(:each) do
      prefab
    end

    describe 'functions' do
      describe 'prop' do
        let(:identifier) { 'prop_column' }
        let(:generator) { "prop('data.string')" }

        it 'applies prop' do
          expect(generated_scope.first.prop_column).to eq('string')
        end
      end

      describe 'concat' do
        let(:identifier) { 'concat_column' }
        let(:generator) { "concat(concat('a', 'b'), 1, true)" }
        let(:referrer) { create :prefab, blueprint: blueprint, data: { prefab: "prefabs/#{prefab.id}" } }
        let(:scope) { Prefab.where(id: referrer.id) }

        it 'applies concat' do
          expect(generated_scope.first.concat_column).to eq("ab1true")
        end
      end

      describe 'lookups' do
        let(:identifier) { 'lookup_column' }
        let(:referent) { create :prefab, blueprint: blueprint, data: data }
        let(:referrer) {
          create :prefab, blueprint: blueprint, data: {
            prefab: "#{referent.namespace}/#{referent.tag}"
          }
        }
        let(:scope) { Prefab.where(id: referrer.id) }

        shared_examples 'lookup_examples' do |lookup_type|
          describe 'simple lookup' do
            it 'applies lookup' do
              expect(generated_scope.first.lookup_column).to eq(expected_value)
            end
          end
        end

        describe 'lookup_s' do
          let(:generator) { 'lookup_s("data.prefab", "data.string")' }
          let(:expected_value) { 'string' }
          include_examples 'lookup_examples', 'text'
        end

        describe 'lookup_i' do ; end
        describe 'lookup_f' do ; end
        describe 'lookup_b' do ; end

        # Chain of references is third -> second -> first
        describe 'lookup chain' do
          let(:third_to_second_uid) { "#{second.namespace}/#{second.tag}" }
          let(:second_to_first_uid) { "#{first.namespace}/#{first.tag}" }
          let(:expected_value) { 'string' }
          let(:first) {
            create :prefab, blueprint: blueprint, data: {
              string: expected_value
            }
          }

          let(:second) {
            create :prefab, blueprint: blueprint, data: {
              string: second_to_first_uid
            }
          }

          let(:third) {
            create :prefab, blueprint: blueprint, data: {
              prefab: third_to_second_uid
            }
          }

          let(:identifier) { 'chained_lookup_column' }
          let(:generator) { 'lookup_s(lookup_s("data.prefab", "data.string"), "data.string")'}
          let(:scope) { Prefab.where(id: third.id) }

          it 'applies lookup' do
            expect(generated_scope.first.chained_lookup_column).to eq(expected_value)
          end

          context 'malicious input' do
            context 'malicious reference uid' do
              let(:second_to_first_uid) { "';--" }
              it 'applies lookup' do
                expect(generated_scope.first.chained_lookup_column).to be_nil
              end
            end

            context 'malicious local lookup key' do
              # The below lets you retrieve data from Prefabs that aren't
              # referenced. Though scoping should prevent pulling data from
              # Prefabs that you don't have access to, the fact that something
              # like this is possible isn't acceptable. Comment the lines
              # in PrefabQueryGenerate that raise errors on disallowed
              # characters, and swap comment lines below to see how it works.
              let(:scope) { Prefab.all }
              let(:third_to_second_uid) { 'prefabs/12345' }
              let(:second_to_first_uid) { 'prefabs/54321' }
              let(:generator) { 'lookup_s("namespace) = \'prefabs\');--", "data.string")' }
              it 'raises error' do
                third
                expect { generated_scope }.to raise_error(Polydesk::Errors::GeneratorFunctionArgumentError)
                # pp generated_scope.map(&:chained_lookup_column)
              end
            end
          end

          context 'malicious remote lookup key' do
            # Similar issue here. This example doesn't actually do anything
            # but you can see the injected SQL, showing this to be an attack
            # vector that has to be dealt with by restricting any characters
            # that can't be an attribute name or data property key path.
            let(:scope) { Prefab.all }
            let(:third_to_second_uid) { 'prefabs/12345' }
            let(:second_to_first_uid) { 'prefabs/54321' }
            let(:generator) { 'lookup_s("data.prefab", ("data__string)), * from prefabs join users as lookup1___data__string --"))' }
            it 'raises error' do
              third
              expect { generated_scope }.to raise_error(Polydesk::Errors::GeneratorFunctionArgumentError)
              # pp generated_scope.map(&:chained_lookup_column)
              # puts generated_scope.to_sql
            end
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
          expect(generated_scope.first.literal_string).to eq('literal_string')
        end

        describe 'validation' do
          context 'with malicious SQL' do
            let(:bad_sql) { "'');--" }
            let(:generator) { "\"#{bad_sql}\"" }

            it 'generates column' do
              expect(generated_scope.first.literal_string).to eq(bad_sql)
            end
          end
        end
      end

      describe 'integer' do
        let(:identifier) { 'literal_integer' }
        let(:generator) { '5' }

        it 'generates column' do
          expect(generated_scope.first.literal_integer).to eq(5)
        end
      end

      describe 'float' do
        let(:identifier) { 'literal_float' }
        let(:generator) { '5.2e3' }

        it 'generates column' do
          expect(generated_scope.first.literal_float).to eq(5.2e3)
        end
      end
    end

    describe 'operators' do
      describe '+' do
        let(:identifier) { 'sum' }
        let(:generator) { '1 + 2.5 + 3' }

        it 'generates column' do
          expect(generated_scope.first.sum).to eq(6.5)
        end
      end

      describe '-' do
        let(:identifier) { 'difference' }
        let(:generator) { '0 - 5.2 - 1' }

        it 'generates column' do
          expect(generated_scope.first.difference).to eq(-6.2)
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
          expect { processor.apply(scope) }.to raise_error(Polydesk::Errors::InvalidGeneratedColumnIdentifier)
        end
      end

      context 'starting with number' do
        let(:identifier) { '1e2' }
        let(:generator) { 'data.number' }

        it 'raises invalid generate identifier error' do
          expect { processor.apply(scope) }.to raise_error(Polydesk::Errors::InvalidGeneratedColumnIdentifier)
        end
      end

      context 'with restricted identifier name' do
        let(:identifier) { 'namespace' }
        let(:generator) { 'data.namespace' }

        it 'raises restricted generate identifier error' do
          expect { processor.apply(scope) }.to raise_error(Polydesk::Errors::RestrictedGeneratedColumnIdentifier)
        end
      end
    end
  end
end
