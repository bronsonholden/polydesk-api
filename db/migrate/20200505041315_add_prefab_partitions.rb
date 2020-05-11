class AddPrefabPartitions < ActiveRecord::Migration[5.2]
  def up
    rename_table :prefabs, :old_prefabs

    create_list_partition :prefabs, partition_key: :namespace, primary_key: :id do |t|
      t.bigint :id, null: false, unique: true
      t.references :blueprint, foreign_key: true, index: true
      t.string :namespace, null: false
      t.json :schema, null: false
      t.json :view, null: false
      t.jsonb :data, null: false
      t.jsonb :flat_data, null: false
      t.timestamps
    end

    execute <<-SQL
      CREATE INDEX index_prefabs_template_on_uid
      ON prefabs_template USING btree ((namespace || '/' || id));
    SQL

    Blueprint.all.each(&:create_prefabs_partition)

    klass = Prefab.deep_dup
    klass.table_name = "old_prefabs"
    klass.all.order(:tag).each { |old|
      if old.blueprint.nil?
        partition_name = Prefab.partition_name(old.namespace)
        if !Prefab.partitions.include?(partition_name)
          Prefab.create_partition values: old.namespace, name: partition_name
        end
        Prefab.create!(namespace: old.namespace,
                       id: old.tag,
                       schema: old.schema,
                       view: old.view,
                       data: old.data)
      else
        Prefab.create!(namespace: old.namespace,
                       id: old.tag,
                       blueprint: old.blueprint,
                       data: old.data)
      end
    }
  end
end
