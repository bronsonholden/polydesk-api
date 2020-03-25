module Applicators::Generate
  class ResourceGenerateApplicator
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
      return scope.select_append("(#{sql}) as \"#{identifier}\""), sql
    end

    protected

    def next_lookup_id
      @lookup_id += 1
    end

    def column_name(table_alias, identifier)
      if identifier.start_with?("data.")
        path = identifier.split('.')[1..-1]
        "((#{table_alias}.data)\#>>'{#{path.join(',')}}')"
      else
        "(#{table_alias}.#{identifier})"
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
        col = column_name(scope.table_name, arg.value)
      else
        scope, col = apply_ast(scope, identifier, arg)
      end
      return scope, col
    end

    def apply_function_sum(scope, cast, identifier, ast)
      arg = ast.children.first
      if arg.is_a?(Keisan::AST::String)
        if !arg.value.match(/^[-_.a-zA-Z0-9]+$/)
          raise Polydesk::Errors::GeneratorFunctionArgumentError.new("Argument at index 0 for #{ast.name}() is a literal with disallowed characters")
        end
        col = column_name('prefabs', arg.value)
      else
        scope, col = apply_ast(scope, identifier, arg)
      end
      return scope.group(:id), "sum((#{col})::#{cast})"
    end

    # Generate a SQL expression for the function specified in the given AST.
    # If applicable, updates and returns the given scope.
    def apply_function(scope, identifier, ast)
      case ast.name
      when 'concat'
        apply_function_concat(scope, identifier, ast)
      when 'prop'
        apply_function_prop(scope, identifier, ast)
      when 'sum_i'
        apply_function_sum(scope, 'integer', identifier, ast)
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
end
