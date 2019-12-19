module Polydesk
  module Blueprints
    class PrefabCriteriaScoping
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

      def self.operand_expression(operand)
        type = operand['type']
        value = operand['value']
        if type == 'literal'
          ActiveRecord::Base.connection.quote(value)
        elsif type == 'property'
          # TODO: Fix to handle arrays
          "data\#>>'{#{operand['key'].gsub(/\./, ',')}}'"
        else
          nil
        end
      end
    end
  end
end
