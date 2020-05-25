class AddNamespaceCheckConstraints < ActiveRecord::Migration[5.2]
  def up
    execute 'ALTER TABLE blueprints ADD CONSTRAINT check_blueprints_on_namespace CHECK (namespace ~* \'^[a-z\-_0-9]+$\')'
    execute 'ALTER TABLE prefabs_template ADD CONSTRAINT check_prefabs_template_on_namespace CHECK (namespace ~* \'^[a-z\-_0-9]+$\')'

    Prefab.partitions.each { |partition|
      execute "ALTER TABLE #{partition} ADD CONSTRAINT check_#{partition}_on_namespace CHECK (namespace ~* '^[a-z\\-_0-9]+$')"
    }
  end

  def down
    Prefab.partitions.each { |partition|
      execute "ALTER TABLE #{partition} DROP CONSTRAINT check_#{partition}_on_namespace"
    }

    execute 'ALTER TABLE prefabs_template DROP CONSTRAINT check_prefabs_template_on_namespace'
    execute 'ALTER TABLE blueprints DROP CONSTRAINT check_blueprints_on_namespace'
  end
end
