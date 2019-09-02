class FormSubmissionSorting
  def initialize(payload)
    @payload = payload.deep_dup
    # Get sorting param
    sort = @payload.fetch('sort', '').split(',')
    # Pick the attributes we will sort with generated SQL
    ext_sort = sort.select { |col|
      col.starts_with?('data') || col.starts_with?('-data')
    }
    # Remove attributes from payload
    sort = sort - ext_sort
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
  end

  def apply(scope)
    @sorting.each { |sort|
      scope = scope.order(Arel.sql(sort))
    }
    return scope
  end

  def payload
    @payload
  end
end
