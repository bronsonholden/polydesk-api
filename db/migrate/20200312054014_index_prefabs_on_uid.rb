class IndexPrefabsOnUid < ActiveRecord::Migration[5.2]
  def self.up
    execute <<-SQL
      CREATE INDEX index_prefabs_on_uid
      ON prefabs USING btree ((namespace || '/' || tag));
    SQL
  end

  def self.down
    execute <<-SQL
      DROP INDEX index_prefabs_on_uid
    SQL
  end
end
