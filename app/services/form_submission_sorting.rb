class FormSubmissionSorting
  attr_reader :custom_selects

  def initialize(payload)
    @meta_aggregates = payload.fetch('meta-aggregate', '').split(',')
    @payload = payload.deep_dup
    # Get sorting param
    sort = @payload.fetch('sort', '').split(',')
    # Pick the attributes we will sort with generated SQL
    ext_sort = sort.select { |col|
      col.starts_with?('data') || col.starts_with?('-data')
    }
    agg_sort = sort.select { |col|
      col.starts_with?('refsum') || col.starts_with?('-refsum') || col.starts_with?('refcount') || col.starts_with?('-refcount')
    }
    # Remove attributes from payload
    sort = sort - ext_sort - agg_sort
    if sort.size > 0
      @payload['sort'] = sort.join(',')
    else
      @payload.delete('sort')
    end
    @sorting = ext_sort.map { |col|
      # Sorting order
      order = 'ASC'
      if col.starts_with?('-')
        # Remove dash
        col = col[1..-1]
        order = 'DESC'
      end
      parts = col.split('.')
      # Remove "data"
      parts = parts[1..-1]
      # Build and sanitize order SQL
      col = parts.reduce('data') { |sql, part|
        "#{sql}->#{ActiveRecord::Base.connection.quote(part)}"
      }
      # Append order
      "#{col} #{order}"
    }
    @agg_sorting = agg_sort.map { |col|
      order = 'ASC'
      if col.starts_with?('-')
        col = col[1..-1]
        order = 'DESC'
      end
      m = col.match(/^(refcount|refsum)\((\d+):([a-zA-Z0-9_\-\.]+):([a-zA-Z0-9_\-\.]+):?([a-zA-Z0-9_\-\.]+)?\)$/)

      if !m.nil?
        rel_form_id = m[2]
        local_alias = m[3].split('.').join('__')
        external_alias = m[4].split('.').join('__')

        local = m[3].split('.').reduce('data') { |sql, part|
          "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
        }
        external = m[4].split('.').reduce('data') { |sql, part|
          "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
        }

        res = {
          expr: col,
          order: order,
          rel_form_id: rel_form_id,
          op: m[1],
          local: local,
          local_alias: local_alias,
          external: external,
          external_alias: external_alias
        }

        if !m[5].nil?
          dimension = m[5].split('.').reduce('data') { |sql, part|
            "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
          }
          dimension_alias = m[5].split('.').join('__')
          res[:dimension] = dimension
          res[:dimension_alias] = dimension_alias
        end

        res
      else
        nil
      end
    }.reject(&:nil?)

    @custom_selects = []
  end

  def apply(scope)
    @sorting.each { |sort|
      scope = scope.order(Arel.sql(sort))
    }
    @agg_sorting.each { |sort|
      if sort[:op] == 'refcount'
        col_name = "count_#{sort[:local_alias]}"
        rel_idx = @meta_aggregates.index(sort[:expr])
        col_name = "rel#{rel_idx}.#{col_name}"
        #select("#{FormSubmission.table_name}.*, rel.#{col_name} AS #{col_name}").joins("left join (select count(id) as #{col_name}, #{Arel.sql(sort[:external])} as rel_dim from form_submissions where form_id = #{Arel.sql(sort[:rel_form_id])} group by #{Arel.sql(sort[:external])}) as rel on rel.rel_dim = id::text")
        scope = scope.order("coalesce(#{col_name}, 0) #{sort[:order]}")
        @custom_selects.push(col_name)
      end
      if sort[:op] == 'refsum'
        col_name = "sum_#{sort[:local_alias]}_#{sort[:dimension_alias]}"
        rel_idx = @meta_aggregates.index(sort[:expr])
        col_name = "rel#{rel_idx}.#{col_name}"
        #select("#{FormSubmission.table_name}.*, rel.#{col_name} as #{col_name}").joins("left join (select sum((#{Arel.sql(sort[:dimension])})::numeric) as #{col_name}, #{Arel.sql(sort[:external])} as rel_dim from form_submissions where form_id = #{Arel.sql(sort[:rel_form_id])} group by #{Arel.sql(sort[:external])}) as rel on rel.rel_dim = id::text")
        scope = scope.order("coalesce(#{col_name}, 0) #{sort[:order]}")
        @custom_selects.push(col_name)
      end
    }
    return scope
  end

  def payload
    @payload
  end
end
