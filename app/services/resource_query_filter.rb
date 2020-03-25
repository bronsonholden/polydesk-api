# ?filter[]=eq(prop('namespace'), 'employees')
# ?filter[]=or(eq(prop('data.title'), 'Janitor'), eq(prop('data.title'), 'Custodian'))
# ?filter[]=neq(generated('full_name'), 'John Doe')

# This service class applies WHERE clauses to a given scope in order to
# filter on model attributes.

class ResourceQueryFilter
  attr_reader :payload

  def initialize(payload)
    @payload = payload.deep_dup
  end

  def apply(scope)
    @scope = scope

    filters = payload.fetch('filter', [])

    if filters.is_a?(String)
      filters = [filters]
    end

    filters.each { |filter|
      scope = evaluate_filter(scope, filter)
    }

    scope
  end

  protected

  def column_name(table_alias, identifier)
    if identifier.start_with?("data.")
      path = identifier.split('.')[1..-1]
      "((#{table_alias}.data)\#>>'{#{path.join(',')}}')"
    else
      "(#{table_alias}.#{identifier})"
    end
  end

  def apply_ast_function(scope, ast)
    case ast.name
    when 'generate'
      arg = ast.children.first
      PrefabQueryGenerate.new({}).apply_ast(scope, nil, arg)
    when 'prop'
      arg = ast.children.first
      if !arg.value.match(/^[._a-zA-Z0-9]+$/)
        raise Polydesk::Errors::InvalidPropertyIdentifier.new(arg.value)
      else
        return scope, "(#{scope.table_name}.#{arg.value})"
      end
    end
  end

  def arg_from_ast(scope, ast)
    case ast
    when Keisan::AST::Function
      apply_ast_function(scope, ast)
    when Keisan::AST::String
      return scope, "#{ActiveRecord::Base.connection.quote(ast.value)}"
    when Keisan::AST::Number
      return scope, "#{ast.value}"
    when Keisan::AST::Boolean
      return scope, "#{ast.value}"
    end
  end

  def apply_ast(scope, ast)
    case ast
    when Keisan::AST::Function
      apply_ast_function(scope, ast)
    when Keisan::AST::LogicalEqual
      scope, lval = arg_from_ast(scope, ast.children.first)
      scope, rval = arg_from_ast(scope, ast.children.second)
      scope.where("(#{lval}) = (#{rval})")
    when Keisan::AST::LogicalNotEqual
      scope, lval = arg_from_ast(scope, ast.children.first)
      scope, rval = arg_from_ast(scope, ast.children.second)
      scope.where("(#{lval}) != (#{rval})")
    end
  end

  def evaluate_filter(scope, filter)
    calculator = Keisan::Calculator.new
    ast = calculator.ast(filter)
    apply_ast(scope, ast)
  end
end
