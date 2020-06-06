require 'rails_helper'

RSpec.describe PrefabControlService do
  let(:group) { create :group }
  let(:account_user) {
    res = AccountUser.first
    res.groups << group
    res
  }
  let(:resolver) { PrefabControlService.new(account_user) }
  let(:base_scope) { Prefab.all }
  let(:resolved_scope) { resolver.apply(base_scope) }

  context 'access control' do
    let(:schema) { { type: 'object' } }
    let(:view) { { stub: true } }
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
