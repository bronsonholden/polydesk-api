module ActiveRecord
  class Relation
    def select_append(*fields)
      if(!select_values.any?)
        fields.unshift(arel_table[Arel.star])
      end
      select(*fields)
    end
  end
end
