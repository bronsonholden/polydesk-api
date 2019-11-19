class FormSubmissionSorting
  def initialize(payload)
    @meta_aggregates = payload.fetch('meta-aggregate', '').split(',')
    @payload = payload.deep_dup
    # Get sorting param
    @sort = payload.fetch('sort', '').split(',')
    if @payload.key?('sort')
      @payload.delete('sort')
    end
  end

  def apply_data_sort(scope, sort)
    # Sorting order
    order = 'ASC'
    if sort.starts_with?('-')
      # Remove dash
      sort = sort[1..-1]
      order = 'DESC'
    end
    parts = sort.split('.')
    # Remove "data"
    parts = parts[1..-1]
    # Build and sanitize order SQL
    sort = parts.reduce('data') { |sql, part|
      "#{sql}->#{ActiveRecord::Base.connection.quote(part)}"
    }
    scope.order("#{sort} #{order}")
  end

  def apply_aggregate_sort(scope, sort)
    order = 'ASC'
    if sort.starts_with?('-')
      sort = sort[1..-1]
      order = 'DESC'
    end
    m = sort.match(/^(select|refcount|refdistinct|refsum|refavg|refmin|refmax)\((\d+):([a-zA-Z0-9_\-\.]+):([a-zA-Z0-9_\-\.]+):?([a-zA-Z0-9_\-\.]+)?\)$/)

    return scope if m.nil?

    rel_form_id = m[2]
    local_alias = m[3].split('.').join('__')
    external_alias = m[4].split('.').join('__')

    local = m[3].split('.').reduce('data') { |sql, part|
      "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
    }
    external = m[4].split('.').reduce('data') { |sql, part|
      "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
    }

    expr = sort
    op = m[1]
    dimension = nil
    dimension_alias = nil

    if !m[5].nil?
      dimension = m[5].split('.').reduce('data') { |sql, part|
        "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
      }
      dimension_alias = m[5].split('.').join('__')
    end

    if op == 'select'
      col_name = "#{local_alias}__#{external_alias}"
      scope = scope.order("#{col_name} #{order}")
    end
    if op == 'refcount'
      col_name = "count_#{local_alias}"
      scope = scope.order("coalesce(#{col_name}, 0) #{order}")
    end
    if op == 'refdistinct'
      col_name = "distinct_#{local_alias}"
      scope = scope.order("coalesce(#{col_name}, 0) #{order}")
    end
    if op == 'refsum'
      col_name = "sum_#{local_alias}_#{dimension_alias}"
      scope = scope.order("coalesce(#{col_name}, 0) #{order}")
    end
    if op == 'refavg'
      col_name = "avg_#{local_alias}_#{dimension_alias}"
      scope = scope.order("coalesce(#{col_name}, 0) #{order}")
    end
    if op == 'refmin'
      col_name = "min_#{local_alias}_#{dimension_alias}"
      scope = scope.order("coalesce(#{col_name}, 0) #{order}")
    end
    if op == 'refmax'
      col_name = "max_#{local_alias}_#{dimension_alias}"
      scope = scope.order("coalesce(#{col_name}, 0) #{order}")
    end

    return scope
  end

  def apply_standard_sort(scope, sort)
    order = :asc
    if sort.starts_with?('-')
      sort = sort[1..-1]
      order = :desc
    end
    col = sort.underscore
    return scope.order(:"#{col}" => order)
  end

  def apply(scope)
    @sort.each { |sort|
      if sort.starts_with?('data') || sort.starts_with?('-data')
        scope = apply_data_sort(scope, sort)
      elsif !sort.match(/^-?(select|refcount|refdistinct|refsum|refavg|refmin|refmax)\(.+\)$/).nil?
        scope = apply_aggregate_sort(scope, sort)
      else
        puts sort
        scope = apply_standard_sort(scope, sort)
      end
    }
    return scope
  end

  def payload
    @payload
  end
end
