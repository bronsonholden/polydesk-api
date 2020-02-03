
# Applies prefab criteria to a given scope. Used filter prefabs for
# searches, reports, or criteria matching.
class PrefabCriteriaScoping
  def self.apply(criteria, scope)
    criteria = JSON.parse(criteria)
    self.apply_condition(criteria['condition'], scope)
  end

  def self.apply_condition(condition, scope)
    sql = self.evaluate_expression(condition)
    if sql.nil? || sql == '()'
      scope
    else
      scope.where(sql)
    end
  end

  def self.unary_expression(expression)
    operator = expression['operator']
    operand = expression['operand']
    if operator == 'not'
      "(NOT #{self.evaluate_expression(operand)})"
    end
  end

  def self.evaluate_expression(operand)
    return if !operand.is_a?(Hash) || operand == {}
    if operand.key?('operand')
      self.unary_expression(operand)
    else
      self.binary_expression(operand)
    end
  end

  def self.binary_expression(operand)
    operator = operand['operator']
    operands = operand['operands']
    operator_symbol = ''
    cast_as = nil
    if operator == 'add'
      operator_symbol = '+'
      cast_as = 'numeric'
    elsif operator == 'sub'
      operator_symbol = '-'
      cast_as = 'numeric'
    elsif operator == 'and' || operator == 'or'
      operator_symbol = " #{operator} "
    elsif operator == 'eq'
      operator_symbol = '='
    end
    expr = operands.map { |operand|
      expr = self.operand_expression(operand)
      if !cast_as.nil?
        "#{expr}::#{cast_as}"
      else
        expr
      end
    }.join(operator_symbol)
    "(#{expr})"
  end

  def self.operand_expression(operand)
    # TODO: Better way to check if operand needs to be expanded
    return self.evaluate_expression(operand) if operand.key?('operator')

    type = operand['type']
    value = operand['value']
    cast = operand['cast']
    if type == 'literal'
      ActiveRecord::Base.connection.quote(value)
    elsif type == 'property'
      path = operand['key'].split('.').map { |part|
        m = part.match(/^([A-Za-z0-9_]+)\[(-?\d+)\]$/)
        if m.nil?
          part
        else
          [m[1], m[2]]
        end
      }.flatten
      "(data\#>>'{#{path.join(',')}}')::#{cast}"
    else
      nil
    end
  end
end
