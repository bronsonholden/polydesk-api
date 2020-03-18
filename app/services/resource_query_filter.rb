# ?filter[namespace]=eq('employees')
# ?filter[data.title]=or(eq('Janitor'), eq('Custodian'))
# ?filter[a_generated_column]=neq('John Doe')

# This service class applies WHERE clauses to a given scope in order to
# filter on model attributes.

class ResourceQueryFilter
  attr_reader :payload

  def initialize(payload)
    @payload = payload.deep_dup
  end

  def apply(scope)
    @scope = scope

    filters = validated_filters(scope)

    filters.each { |dimension, filter|
      scope = evaluate_filter(scope, dimension, filter)
    }

    scope
  end

  protected

  def arg_from_ast(scope, dimension, ast)
    case ast
    when Keisan::AST::Variable
      if scope.column_names.include?(ast.name)
        "prefabs.#{ast.name}"
      else
        '(null)'
      end
    when Keisan::AST::String
      "#{ActiveRecord::Base.connection.quote(ast.value)}"
    when Keisan::AST::Number
      "#{ast.value}"
    when Keisan::AST::Boolean
      "#{ast.value}"
    end
  end

  def apply_ast_function(scope, dimension, ast)
    comparators = {
      'eq' => '=',
      'neq' => '!=',
      'gt' => '>',
      'gte' => '>=',
      'lt' => '<',
      'lte' => '<='
    }

    comparator = comparators[ast.name]
    if comparator.nil?
      # TODO
      raise "Unknown comparator function: #{ast.name}"
    end

    scope.where("#{dimension} #{comparator} #{arg_from_ast(scope, dimension, ast.children.first)}")
  end

  def apply_ast(scope, dimension, ast)
    case ast
    when Keisan::AST::Function
      apply_ast_function(scope, dimension, ast)
    end
  end

  def evaluate_filter(scope, dimension, filter)
    calculator = Keisan::Calculator.new
    ast = calculator.ast(filter)
    if ast.is_a?(Keisan::AST::Function)
      apply_ast(scope, dimension, ast)
    else
      scope
    end
  end

  def valid_dimension_identifier?(dimension, scope)
    scope.column_names.include?(dimension)
  end

  # Validate the requested filters (are they valid columns?)
  def validated_filters(scope)
    query_filter = payload.fetch('filter', {})

    query_filter.each { |dimension, filter|
      if !valid_dimension_identifier?(dimension, scope)
        raise Polydesk::Errors::InvalidFilterDimensionIdentifier.new(dimension, "must be a valid resource attribute: #{scope.column_names.join(', ')}")
      end
    }

    query_filter
  end
end
