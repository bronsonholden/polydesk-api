module Applicators::Filter
  class ResourceFilterApplicator
    attr_reader :query

    def initialize(query)
      @query = query
    end

    def apply(scope, filter)
      calculator = Keisan::Calculator.new
      ast = calculator.ast(filter)
      apply_ast(scope, ast)
    end

    protected

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

    def apply_function_json(scope, cast, ast)
      arg = ast.children.first
      if !arg.is_a?(Keisan::AST::String)
        raise "must be a string"
      elsif !arg.value.match(/^([-_a-zA-Z0-9]+\.)*[-_a-zA-Z0-9]+$/)
        raise "must be a dot-separated JSON path e.g. 'name.first'"
      else
        path = arg.value.split('.')
        prop = path.shift
        if !prop.match(/^[a-z_]+$/)
          raise "invalid JSON attribute identifier: alphanumerics and _ only"
        else
          return scope, "(((#{scope.table_name}.#{prop})\#>>'{#{path.join(',')}}')::#{cast})"
        end
      end
    end

    def apply_ast_function(scope, ast)
      case ast.name
      when 'generate'
        arg = ast.children.first
        query.generate_applicator.apply(scope, nil, arg.to_s)
      when 'json_s'
        apply_function_json(scope, 'text', ast)
      when 'json_i'
        apply_function_json(scope, 'integer', ast)
      when 'json_f'
        apply_function_json(scope, 'float', ast)
      when 'json_b'
        apply_function_json(scope, 'boolean', ast)
      when 'prop'
        arg = ast.children.first
        if !arg.is_a?(Keisan::AST::String)
          raise "must be a string"
        elsif !scope.column_names.include?(arg.value)
          raise Polydesk::Errors::InvalidPropertyIdentifier.new(arg.value)
        else
          return scope, "(#{scope.table_name}.#{arg.value})"
        end
      end
    end

    def apply_ast_comparator(scope, ast)
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
      else
        raise "unknown operator #{ast.class}"
      end
      scope, lval = arg_from_ast(scope, ast.children.first)
      scope, rval = arg_from_ast(scope, ast.children.second)
      scope.where("(#{lval}) #{operator} (#{rval})")
    end

    def apply_ast(scope, ast)
      if ast.is_a?(Keisan::AST::Function)
        apply_ast_function(scope, ast)
      elsif ast.is_a?(Keisan::AST::LogicalOperator)
        apply_ast_comparator(scope, ast)
      end
    end
  end
end
