class FormSubmissionFiltering
  def initialize(payload)
    @payload = payload.deep_dup
    @filters = payload.fetch('filter', {}).to_h

    @filters.each { |key, value|
      v = value
      if v.is_a?(String)
        v = v.split(',')
      end
      @filters[key] = v.map { |expr|
        res = expr.scan(/\A(!?ge|!?gt|!?le|!?lt|!?in|!?has|!?eq)\:([^\:].*)\z/)
        if res.size == 1
          res.first
        else
          ['eq', value]
        end
      }
    }

    # Pick the attributes we will sort with generated SQL
    ext_filter = @filters.select { |key, val|
      key.starts_with?('data.')
    }
    @filters = @filters.reject { |f| ext_filter.key?(f) }

    @json_filters = {}
    ext_filter.each { |key, val|
      parts = key.split('.')
      # Remove "data"
      parts = parts[1..-1]
      # Build and sanitize order SQL
      col = "(data\#>>'{#{parts.join(',')}}')"
      @json_filters[col] = val
    }
  end

  def apply_condition(attr, cond, scope)
    operator = cond[0]
    operand = URI.decode(cond[1])
    if operand.is_a?(String)
      operand = Arel.sql(operand)
    else
      operand = operand.map { |v| Arel.sql(v) }
    end
    if operator == 'eq'
      scope.where("#{attr} = ?", operand)
    elsif operator == '!eq'
      scope.where("(#{attr}) != ?", operand)
    elsif operator == 'gt' || operator == '!le'
      scope.where("(#{attr})::float > ?", operand.to_f)
    elsif operator == 'ge' || operator == '!lt'
      scope.where("(#{attr})::float >= ?", operand.to_f)
    elsif operator == 'lt' || operator == '!ge'
      scope.where("(#{attr})::float < ?", operand.to_f)
    elsif operator == 'le' || operator == '!gt'
      scope.where("(#{attr})::float <= ?", operand.to_f)
    elsif operator == 'in'
      vals = CSV.parse(operand).first
      scope.where("#{attr} in (?)", vals)
    end
  end

  def apply(scope)
    @filters.each { |attr, conditions|
      conditions.each { |c|
        if c.size == 2
          scope = apply_condition(attr.underscore, c, scope)
        end
      }
    }
    @json_filters.each { |attr, conditions|
      conditions.each { |c|
        if c.size == 2
          scope = apply_condition(attr, c, scope)
        end
      }
    }
    return scope
  end

  def payload
    @payload
  end
end
