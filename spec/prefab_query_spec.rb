require 'rails_helper'

RSpec.describe PrefabQuery do
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
  let(:query) { PrefabQuery.new(payload) }

  # Scope with generated columns applied
  let(:applied_scope) { query.apply(scope) }

  # Base scope to use when generating columns
  let(:scope) { Prefab.all }

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
          expect(applied_scope.first.lookup_column).to eq(expected_value)
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
        expect(applied_scope.first.chained_lookup_column).to eq(expected_value)
      end

      context 'malicious input' do
        context 'malicious reference uid' do
          let(:second_to_first_uid) { "';--" }
          it 'applies lookup' do
            expect(applied_scope.first.chained_lookup_column).to be_nil
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
            expect { applied_scope }.to raise_error(Polydesk::Errors::GeneratorFunctionArgumentError)
            # pp applied_scope.map(&:chained_lookup_column)
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
          expect { applied_scope }.to raise_error(Polydesk::Errors::GeneratorFunctionArgumentError)
          # pp applied_scope.map(&:chained_lookup_column)
          # puts applied_scope.to_sql
        end
      end
    end
  end
end
