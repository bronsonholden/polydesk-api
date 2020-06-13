require 'rails_helper'

RSpec.describe PrefabControlService do
  let(:schema) { { type: 'object' } }
  let(:view) { { stub: true } }
  let(:group) { create :group }
  let(:account_user) {
    res = AccountUser.first
    res.groups << group
    res
  }
  let(:resolver) { PrefabControlService.new(account_user) }
  let(:base_scope) { Prefab.all }
  let(:resolved_scope) { resolver.apply(base_scope) }

  describe 'data control' do
    let(:data) {
      {
        mode: 'mode',
        string: 'string',
        integer: 1,
        float: 1.5,
        boolean: true
      }
    }

    let(:base_mode) { 1 }
    let(:employees_blueprint) { create :blueprint, name: 'Employees', namespace: 'employees', schema: schema, view: view }
    # Control that allows view
    let(:base_data_control) { create :data_control, namespace: 'employees', key: 'mode', value: 'mode', mode: base_mode, group: group }
    # Unrestricted Prefab has only the "view" key, so it is unaffected by any
    # other data controls being tested.
    let(:unrestricted_employee) { create :prefab, blueprint: employees_blueprint, data: { mode: 'mode' } }
    let(:active_data_control) { create :data_control, namespace: 'employees', key: key, value: value, operator: operator, mode: control_mode, group: group }
    let(:restricted_employee) { create :prefab, blueprint: employees_blueprint, data: data }
    let(:blah_employee) { create :prefab, blueprint: employees_blueprint, data: { leaveme: 'alone' } }

    before(:each) do
      base_data_control
      active_data_control
      restricted_employee
      unrestricted_employee
    end

    shared_examples 'data_control_examples' do
      context 'whitelist over no access' do
        let(:base_mode) { 0 }
        let(:control_mode) { 1 }

        it 'provides access to restricted prefab' do
          expect(resolved_scope.to_a.map(&:uid)).to all(eq(restricted_employee.uid))
        end
      end

      context 'whitelist over access' do
        let(:base_mode) { 1 }
        let(:control_mode) { 1 }

        it 'provides access to both prefabs' do
          expect(resolved_scope.to_a.map(&:uid)).to include(restricted_employee.uid, unrestricted_employee.uid)
        end
      end

      context 'blacklist over no access' do
        let(:base_mode) { 0 }
        let(:control_mode) { 0 }

        it 'provides access to no prefabs' do
          expect(resolved_scope.size).to eq(0)
        end
      end

      context 'blacklist over access' do
        let(:base_mode) { 1 }
        let(:control_mode) { 0 }

        it 'provides access to unrestricted prefab' do
          expect(resolved_scope.to_a.map(&:uid)).to all(eq(unrestricted_employee.uid))
        end
      end
    end

    describe 'eq' do
      let(:operator) { 'eq' }
      let(:key) { 'string'}
      let(:value) { 'string' }
      include_examples 'data_control_examples'
    end

    describe 'neq' do
      let(:operator) { 'neq' }
      let(:key) { 'string' }
      let(:value) { 'notstring' }
      include_examples 'data_control_examples'
    end

    describe 'lt' do
      let(:operator) { 'lt' }
      let(:key) { 'integer' }
      let(:value) { 2 }
    end

    describe 'lte' do
      let(:operator) { 'lte' }
      let(:key) { 'integer' }
      let(:value) { 5 }
      include_examples 'data_control_examples'
    end

    describe 'gt' do
      let(:operator) { 'gt' }
      let(:key) { 'integer' }
      let(:value) { 0 }
      include_examples 'data_control_examples'
    end

    describe 'gte' do
      let(:operator) { 'gte' }
      let(:key) { 'integer' }
      let(:value) { 0 }
      include_examples 'data_control_examples'
    end
  end

  context 'access control' do
    let(:employees_blueprint) { create :blueprint, name: 'Employees', namespace: 'employees', schema: schema, view: view }
    let(:clients_blueprint) { create :blueprint, name: 'Clients', namespace: 'clients', schema: schema, view: view }
    let(:employees_allow) { create :access_control, group: group, namespace: 'employees', mode: 1 }
    let(:clients_allow) { create :access_control, group: group, namespace: 'clients', mode: 1 }
    let(:employees_deny) { create :access_control, group: group, namespace: 'employees', mode: 0 }
    let(:employee_prefab) { create :prefab, blueprint: employees_blueprint, data: { name: 'John Doe' } }
    let(:client_prefab) { create :prefab, blueprint: clients_blueprint, data: { name: 'ACME, Inc' } }
    # This secondary group & access is a sanity check to ensure that Prefabs
    # aren't duplicated in the result when there are multiple controls that
    # apply to them.
    let(:secondary_group) {
      g = create :group, name: 'Secondary Group'
      account_user.groups << g
      g
    }
    let(:secondary_access) { create :access_control, group: secondary_group, namespace: 'employees', mode: 1 }

    before(:each) do
      employee_prefab
      client_prefab
    end

    context 'with no access control' do
      it 'returns no prefabs' do
        expect(resolved_scope.to_a.size).to eq(0)
      end
    end

    context 'with allowed access' do
      it 'returns prefabs in both namespaces' do
        secondary_access
        employees_allow
        clients_allow
        # Resolved scope should allow access to Prefabs from both namespaces
        expect(resolved_scope.to_a).to all(be_a(Prefab))
        expect(resolved_scope.to_a.size).to eq(2)
        expect(resolved_scope.to_a.map(&:namespace)).to include('employees', 'clients')
      end
    end

    context 'with overriding deny access' do
      it 'returns prefab in only whitelisted namespace' do
        secondary_access
        # Even though an "Allow" access control is in place for the
        # "employees" namespace, the "Deny" control that is applied overrides
        # it, providing access only to the "clients" namespace
        employees_allow
        employees_deny
        clients_allow
        expect(resolved_scope.to_a).to all(be_a(Prefab))
        expect(resolved_scope.to_a.size).to eq(1)
        expect(resolved_scope.to_a.map(&:namespace)).to all(eq('clients'))
      end
    end
  end

  describe 'test' do
    it 'works' do
      resolved_scope
    end
  end
end
