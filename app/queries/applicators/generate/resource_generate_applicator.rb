# This class generates custom columns using expressions that are parsed and
# converted into SQL. These expressions are not directly injected into the
# query string. The expression is parsed into an AST which, when traversed,
# will generate and apply appropriate SQL expression(s). Any literal values
# (which are directly inserted into the query) are scrubbed to prevent SQL
# injection; functions and operators are inserted as pre-defined SQL analogs,
# e.g. SQL CONCAT() expressions are generated from the concat() generator
# expression. This is basically a transpiler that whitelists SQL functions
# and provides a more URL- and human-friendly syntax.
#
# Other areas of concern are column identifiers and table aliases: column
# identifiers are scrubbed when the applicator updates the given scope
# to ensure no malicious SQL makes its way into the query. Table aliases are
# generated using simple character replacement on the Prefab data key paths.
# Since Blueprints will reject any schema with object properties that have
# keys containing characters other than alphanumerics, underscores, and
# dashes, the only character that could cause issues in the table alias is
# the path separator (dots). This is replaced and the resulting table alias
# consists of only alphanumerics, underscores, dashes, and dots. A regex
# match is used to verify this as an added layer of security.
#
# Column identifiers must consist only of alphanumerics and underscores (but
# may not begin with a number, and be distinct from the built-in attributes
# of the Prefab model.
#
# The generate query parameter must be a hash, where each key is a column
# identifier, and the corresponding value is an expression called a generator.
# If an error occurs during the evaluation of a generator, the entire query
# fails, not just the offending Prefab. This can be avoided by ensuring
# uniformity across all Prefabs using well-managed migrations to deal with
# evolving models.
class Applicators::Generate::ResourceGenerateApplicator
  attr_reader :query

  def initialize(query)
    @query = query
    # A counter that is used to give each lookup table alias a unique number
    # to prevent alias conflicts when chaining lookups that return values at
    # the same path, e.g. lookup_s(lookup_s("data.a", "data.b"), "data.b")
    # In this example, both lookups will end up with the same assigned table
    # alias.
    @lookup_id = 0
  end

  def apply(scope, identifier, generator)
    calculator = Keisan::Calculator.new
    ast = calculator.ast(generator)
    scope, sql = apply_ast(scope, identifier, ast)
    if !identifier.nil?
      scope = scope.select_append("(#{sql}) as \"#{identifier}\"")
    end
    return scope, sql
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

  def apply_function_concat(scope, identifier, ast)
    args = ast.children.map { |arg|
      scope, sql = apply_ast(scope, identifier, arg)
      "(#{sql}::text)"
    }

    return scope, "(concat(#{args.join(',')}))"
  end

  def apply_function_prop(scope, identifier, ast)
    arg = ast.children.first
    if arg.is_a?(Keisan::AST::String)
      if !arg.value.match(/^[-_.a-zA-Z0-9]+$/)
        raise Polydesk::Errors::GeneratorFunctionArgumentError.new("Argument at index 0 for #{ast.name}() is a literal with disallowed characters")
      end
      col = column_name(scope, scope.table_name, arg.value)
    else
      scope, col = apply_ast(scope, identifier, arg)
    end
    return scope, col
  end

  # Generate a SQL expression for the function specified in the given AST.
  # If applicable, updates and returns the given scope.
  def apply_function(scope, identifier, ast)
    case ast.name
    when 'concat'
      apply_function_concat(scope, identifier, ast)
    when 'prop'
      apply_function_prop(scope, identifier, ast)
    else
      return scope, 'null'
    end
  end

  def apply_ast(scope, identifier, ast)
    case ast
    when Keisan::AST::ArithmeticOperator
      sql = ast.children.map { |operand|
        scope, operand_sql = apply_ast(scope, identifier, operand)
        operand_sql
      }.join(ast.class.symbol.to_s)
      sql = "(#{sql})"
    when Keisan::AST::UnaryInverse
      scope, operand_sql = apply_ast(scope, identifier, ast.children.first)
      sql = "(1.0 / (#{operand_sql}))"
    when Keisan::AST::UnaryOperator
      scope, operand_sql = apply_ast(scope, identifier, ast.children.first)
      sql = "#{ast.class.symbol.to_s}(#{operand_sql})"
    when Keisan::AST::Function
      scope, sql = apply_function(scope, identifier, ast)
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
end
