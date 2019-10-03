class FormSubmissionSorting
  def initialize(payload)
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
      m = col.match(/^(refcount|refsum)\(([a-zA-Z0-9_\-\.]+):([a-zA-Z0-9_\-\.]+):?([a-zA-Z0-9_\-\.]+)?\)$/)

      return nil if m.nil?

      local = m[2].split('.').reduce('data') { |sql, part|
        "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
      }
      external = m[3].split('.').reduce('data') { |sql, part|
        "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
      }

      res = { order: order, op: m[1], local: external, external: external }

      if !m[4].nil?
        dimension = m[4].split('.').reduce('data') { |sql, part|
          "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
        }
        res[:dimension] = dimension
      end

      res
    }
    puts @agg_sorting.inspect
  end

  def apply(scope)
    @sorting.each { |sort|
      scope = scope.order(Arel.sql(sort))
    }
    @agg_sorting.each { |sort|
      if sort[:op] == 'refcount'
        scope = scope.joins("left join (select count(id) as rel_count, #{sort[:external]} as rel_dim from form_submissions group by #{sort[:external]}) as rel on rel.rel_dim = id::text").order("rel_count #{sort[:order]}")
      end
      if sort[:op] == 'refsum'
        scope = scope.joins("left join (select sum((#{sort[:dimension]})::numeric) as rel_sum, #{sort[:external]} as rel_dim from form_submissions group by #{sort[:external]}) as rel on rel.rel_dim = id::text").order("rel_sum #{sort[:order]}")
      end
    }
    # FormSubmission
    #   .where(form_id: 2)
    #   .joins("left join (select count(id) as rel_count, data->>'ranch' as rel_dim from form_submissions group by data->>'ranch') as rel on rel.rel_dim = id::text")
    #   .order("rel_count ASC")
    # FormSubmission
    #   .where(form_id: 2)
    #   .joins("left join (select sum((data->>'acres')::float) as rel_count, data->>'ranch' as rel_dim from form_submissions group by data->>'ranch') as rel on rel.rel_dim = id::text")
    #   .order("rel_count ASC")
    return scope
  end

  def payload
    @payload
  end
end
