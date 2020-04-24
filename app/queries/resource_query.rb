
class ResourceQuery
  attr_reader :payload

  def initialize(payload)
    @payload = payload.deep_dup
    # A counter that is used to give each lookup table alias a unique number
    # to prevent alias conflicts when chaining lookups that return values at
    # the same path, e.g. lookup_s(lookup_s("data.a", "data.b"), "data.b")
    # In this example, both lookups will end up with the same assigned table
    # alias.
    @lookup_id = 0
  end

  def apply(scope)
    scope = apply_generators(scope)
    scope = apply_filters(scope)
    scope
  end

  private

  def boolean_function?(ast)
    if ast.is_a?(Keisan::AST::Function)
      return ast.name == 'and' || ast.name == 'or'
    else
      return false
    end
  end

  protected

  def next_lookup_id
    @lookup_id += 1
  end

  def column_name(scope, table_alias, identifier)
    if identifier.start_with?("data.")
      path = identifier.split('.')[1..-1]
      "((#{table_alias}.data)\#>>'{#{path.join(',')}}')"
    elsif scope.column_names.include?(identifier)
      "(#{table_alias}.#{identifier})"
    else
      raise Polydesk::Errors::InvalidPropertyIdentifier.new(identifier)
    end
  end

  def apply_expression(scope, expression)
    ast = Keisan::Calculator.new.ast(expression)
    apply_ast(scope, ast)
  end

  def apply_filter_expression(scope, expression)
    ast = Keisan::Calculator.new.ast(expression)
    if ast.is_a?(Keisan::AST::LogicalOperator) || boolean_function?(ast)
      apply_ast(scope, ast)
    else
      raise Polydesk::Errors::InvalidFilterExpression.new
    end
  end

  def apply_function_concat(scope, ast)
    args = ast.children.map { |arg|
      scope, sql = apply_ast(scope, arg)
      "(#{sql}::text)"
    }

    return scope, "(concat(#{args.join(',')}))"
  end

  def apply_function_coalesce(scope, ast)
    primary, fallback = ast.children
    scope, primary_sql = apply_ast(scope, primary)
    scope, fallback_sql = apply_ast(scope, fallback)
    return scope, "coalesce(#{primary_sql}, #{fallback_sql})"
  end

  def apply_function_lower(scope, ast)
    scope, str = apply_ast(scope, ast.children.first)
    return scope, "lower(#{str})"
  end

  def apply_function_upper(scope, ast)
    scope, str = apply_ast(scope, ast.children.first)
    return scope, "upper(#{str})"
  end

  def apply_function_prop(scope, ast)
    arg = ast.children.first
    if arg.is_a?(Keisan::AST::String)
      col = column_name(scope, scope.table_name, arg.value)
    else
      scope, col = apply_ast(scope, arg)
    end
    return scope, col
  end

  def apply_function_sqrt(scope, ast)
    arg = ast.children.first
    if arg.is_a?(Keisan::AST::Number)
      sql = "#{arg.value}"
    else
      scope, sql = apply_ast(scope, arg)
    end
    return scope, "sqrt(#{sql}::numeric)"
  end

  def apply_function_pow(scope, ast)
    base, exponent = ast.children
    scope, base = apply_ast(scope, base)
    scope, exponent = apply_ast(scope, exponent)
    return scope, "power(#{base}::numeric, #{exponent}::numeric)"
  end

  def apply_function_log(scope, ast)
    num, base = ast.children
    scope, num = apply_ast(scope, num)
    if base.nil?
      return scope, "log(#{num}::numeric)"
    else
      scope, base = apply_ast(scope, base)
      return scope, "log(#{base}::numeric, #{num}::numeric)"
    end
  end

  def apply_function_ln(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "ln(#{num}::numeric)"
  end

  def apply_function_exp(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "exp(#{num}::numeric)"
  end

  def apply_function_abs(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "abs(#{num}::numeric)"
  end

  def apply_function_floor(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "floor(#{num}::numeric)"
  end

  def apply_function_ceil(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "ceil(#{num}::numeric)"
  end

  def apply_function_round(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "round(#{num}::numeric)"
  end

  def apply_function_current_date(scope, ast)
    if ast.children.empty?
      return scope, "date(current_date at time zone 'UTC')"
    else
      scope, tz = apply_ast(scope, ast.children.first)
      return scope, "date(current_date at time zone #{tz})"
    end
  end

  def apply_function_current_timestamp(scope, ast)
    return scope, "(current_timestamp)"
  end

  def apply_function_interval(scope, ast)
    scope, amount = apply_ast(scope, ast.children.first)
    scope, unit = apply_ast(scope, ast.children.second)
    return scope, "(concat(#{amount}, ' ', #{unit})::interval)"
  end

  # Generate a SQL expression for the function specified in the given AST.
  # If applicable, updates and returns the given scope.
  def apply_function(scope, ast)
    case ast.name
    when 'concat'
      apply_function_concat(scope, ast)
    when 'lower'
      apply_function_lower(scope, ast)
    when 'upper'
      apply_function_upper(scope, ast)
    when 'prop'
      apply_function_prop(scope, ast)
    when 'coalesce'
      apply_function_coalesce(scope, ast)
    when 'sqrt'
      apply_function_sqrt(scope, ast)
    when 'pow'
      apply_function_pow(scope, ast)
    when 'log'
      apply_function_log(scope, ast)
    when 'ln'
      apply_function_ln(scope, ast)
    when 'exp'
      apply_function_exp(scope, ast)
    when 'abs'
      apply_function_abs(scope, ast)
    when 'round'
      apply_function_round(scope, ast)
    when 'floor'
      apply_function_floor(scope, ast)
    when 'ceil'
      apply_function_ceil(scope, ast)
    when 'current_date'
      apply_function_current_date(scope, ast)
    when 'current_timestamp'
      apply_function_current_timestamp(scope, ast)
    when 'interval'
      apply_function_interval(scope, ast)
    else
      return scope, 'null'
    end
  end

  def apply_variable(scope, ast)
    case ast.name
    when 'PI'
      return scope, "pi()"
    when 'E'
      return scope, "exp(1.0)"
    end
  end

  def apply_ast_binary_operator(scope, ast, symbol: ast.class.symbol.to_s)
    sql = ast.children.map { |operand|
      scope, operand_sql = apply_ast(scope, operand)
      operand_sql
    }.join(symbol)
    return scope, "(#{sql})"
  end

  def apply_ast_logical_operator(scope, ast)
    case ast
    when Keisan::AST::LogicalEqual
      operator = '='
    when Keisan::AST::LogicalNotEqual
      operator = '!='
    when Keisan::AST::LogicalGreaterThan
      operator = '>'
    when Keisan::AST::LogicalLessThan
      operator = '<'
    when Keisan::AST::LogicalGreaterThanOrEqualTo
      operator = '>='
    when Keisan::AST::LogicalLessThanOrEqualTo
      operator = '<='
    when Keisan::AST::LogicalOr
      operator = 'OR'
    when Keisan::AST::LogicalAnd
      operator = 'AND'
    else
      raise "unknown operator #{ast.class}"
    end
    args = ast.children.map { |arg|
      scope, sql = apply_ast(scope, arg)
      "(#{sql})"
    }
    return scope, "(#{args.join(" #{operator} ")})"
  end

  def apply_ast(scope, ast)
    case ast
    when Keisan::AST::LogicalOperator
      scope, sql = apply_ast_logical_operator(scope, ast)
    when Keisan::AST::ArithmeticOperator
      scope, sql = apply_ast_binary_operator(scope, ast)
    when Keisan::AST::BitwiseXor
      scope, sql = apply_ast_binary_operator(scope, ast, symbol: '#')
    when Keisan::AST::BitwiseOperator
      scope, sql = apply_ast_binary_operator(scope, ast)
    when Keisan::AST::UnaryInverse
      scope, operand_sql = apply_ast(scope, ast.children.first)
      sql = "(1.0 / (#{operand_sql}))"
    when Keisan::AST::UnaryOperator
      scope, operand_sql = apply_ast(scope, ast.children.first)
      sql = "#{ast.class.symbol.to_s}(#{operand_sql})"
    when Keisan::AST::Variable
      scope, sql = apply_variable(scope, ast)
    when Keisan::AST::Function
      scope, sql = apply_function(scope, ast)
    when Keisan::AST::String
      sql = "#{ActiveRecord::Base.connection.quote(ast.value)}"
    when Keisan::AST::Number
      sql = "#{ast.value}"
    when Keisan::AST::Boolean
      sql = "#{ast.value}"
    else
      sql = 'null'
    end
    return scope, sql
  end

  def apply_filters(scope)
    filters = payload.fetch('filter', [])

    if filters.is_a?(String)
      filters = [filters]
    end

    filters.each { |filter|
      scope, sql = apply_filter_expression(scope, filter)
      scope = scope.where("(#{sql})")
    }

    scope
  end

  def apply_generators(scope)
    generate = payload.fetch('generate', {})

    reserved_identifiers = scope.column_names
    generate.keys.each { |key|
      # Verify that no identifiers exactly match existing attributes.
      # Re-used identifiers will simply be overwritten, but we need to make
      # sure that attributes like namespace can't be replaced.
      if reserved_identifiers.include?(key)
        raise Polydesk::Errors::RestrictedGeneratedColumnIdentifier.new(key)
      end

      # Check that identifiers are using only alphanumerics and _, and
      # don't start with a number.
      if !key.match(/^[a-zA-Z_]+[a-zA-Z0-9_]*$/)
        raise Polydesk::Errors::InvalidGeneratedColumnIdentifier.new(key)
      end
    }

    generate.each { |identifier, generator|
      scope, sql = apply_expression(scope, generator)
      scope = scope.select_append("(#{sql}) as \"#{identifier}\"")
    }

    scope
  end
end
