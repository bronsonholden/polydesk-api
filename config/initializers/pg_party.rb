require 'pg_party/model_decorator'

# Open the ModelDecorator class and modify the #partitions method to return
# results only within the current tenant schema. This corrects the issue
# wherein #partitions returns the cardinal set of all partitions and tenant
# schemas.
module PgParty
  ModelDecorator.class_eval do
    def partitions
      ActiveRecord::Base.connection.select_values(<<-SQL)
        SELECT pg_inherits.inhrelid::regclass::text
        FROM pg_tables
        INNER JOIN pg_inherits
          ON pg_tables.tablename::regclass = pg_inherits.inhparent::regclass
        WHERE pg_tables.tablename = #{connection.quote(table_name)}
          AND pg_tables.schemaname = #{connection.quote(Apartment::Tenant.current)}
      SQL
    rescue
      []
    end
  end
end
