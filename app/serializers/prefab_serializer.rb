class PrefabSerializer < TenantSerializer
  attributes :namespace, :schema, :view, :data, :created_at, :updated_at
  has_one :blueprint, class_name: 'Blueprint'

  def meta
    virtual_columns = object.attributes.keys - object.class.column_names
    if virtual_columns.any?
      meta = {}
      virtual_columns.map(&:to_sym).each { |col|
        meta[col] = object.send(col)
      }
      meta
    else
      nil
    end
  end
end
