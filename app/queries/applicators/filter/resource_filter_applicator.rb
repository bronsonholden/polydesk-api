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

    def apply_ast_function(scope, ast)
      case ast.name
      when 'generate'
        arg = ast.children.first
        query.generate_applicator.apply(scope, nil, arg.to_s)
      when 'prop'
        arg = ast.children.first
        if !arg.value.match(/^[._a-zA-Z0-9]+$/)
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
