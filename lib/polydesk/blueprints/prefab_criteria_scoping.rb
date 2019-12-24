module Polydesk
  module Blueprints
    module PrefabCriteriaScoping
      def self.apply(criteria, scope)
        criteria = JSON.parse(criteria)
        self.apply_condition(criteria['condition'], scope)
      end

      def self.apply_condition(condition, scope)
        operator = condition['operator']
        operands = condition['operands']
        if operator == 'eq'
          scope.where("#{self.operand_expression(operands[0])} = #{self.operand_expression(operands[1])}")
        end
      end

      def self.evaluate_operand(operand)
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
        end
        operands.map { |operand|
          expr = self.operand_expression(operand)
          if !cast_as.nil?
            "#{expr}::#{cast_as}"
          else
            expr
          end
        }.join(operator_symbol)
      end

      def self.operand_expression(operand)
        if operand.key?('operator')
          self.evaluate_operand(operand)
        else
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
    end
  end
end
