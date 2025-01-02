require "qubit/condition"

module Qubit
  class ConditionParser
    class << self
      def parse(condition_string)
        tokens = tokenize(condition_string)
        parse_expression(tokens)
      end

      private

      def tokenize(str)
        tokens = []
        scanner = StringScanner.new(str)
        
        until scanner.eos?
          scanner.skip(/\s+/)
          
          case
          when scanner.scan(/!/)
            tokens << scanner.matched
          when scanner.scan(/&&/)
            tokens << scanner.matched
          when scanner.scan(/\|\|/)
            tokens << scanner.matched
          when scanner.scan(/[()]/)
            tokens << scanner.matched
          when scanner.scan(/\w+/)
            tokens << scanner.matched
          else
            raise ParserError, "Invalid token at position #{scanner.pos}: #{str[scanner.pos]}"
          end
        end

        tokens
      end

      def parse_expression(tokens, precedence = 0)
        lhs = parse_unary(tokens)
        
        while tokens.any? && precedence < precedence_of(tokens.first)
          operator = tokens.shift
          
          case operator
          when '&&'
            rhs = parse_expression(tokens, precedence_of(operator))
            lhs = Condition.new(operation: :and, children: [lhs, rhs])
          when '||' 
            rhs = parse_expression(tokens, precedence_of(operator))
            lhs = Condition.new(operation: :or, children: [lhs, rhs])
          end
        end

        lhs
      end

      def parse_unary(tokens)
        token = tokens.first

        case token
        when '!'
          tokens.shift
          child = parse_unary(tokens)
          Condition.new(operation: :not, children: [child])
        when '('
          tokens.shift
          expr = parse_expression(tokens)
          raise ParserError, "Expected ')'" unless tokens.shift == ')'
          expr
        else
          tokens.shift
          Condition.new(name: token.to_sym)
        end
      end

      def precedence_of(token)
        case token
        when '||' then 1
        when '&&' then 2
        else 0
        end
      end
    end

    class ParserError < StandardError; end
  end
end