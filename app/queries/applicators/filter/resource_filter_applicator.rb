module Applicators::Filter
  class ResourceFilterApplicator
    attr_reader :query

    def initialize(query)
      @query = query
      @filter_id = 0
    end

    def apply(scope, filter)
      calculator = Keisan::Calculator.new
      ast = calculator.ast(filter)
      apply_ast(scope, ast)
    end

    protected

    def next_filter_id
      @filter_id += 1
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

    def apply_ast_function(scope, ast)
      case ast.name
      when 'generate'
        arg = ast.children.first
        query.generate_applicator.apply(scope, "filter#{next_filter_id}", arg.to_s)
      when 'prop'
        arg = ast.children.first
        if !arg.value.match(/^[._a-zA-Z0-9]+$/)
          raise Polydesk::Errors::InvalidPropertyIdentifier.new(arg.value)
        else
          return scope, "(#{scope.table_name}.#{arg.value})"
        end
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
  end
end
