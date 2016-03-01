# The Standard NLP engine for Masqueraide.
# A good starting point for your own NLP engine to work with Masqueraide.
# Custom engines must be a module of 'Masqueraide::Engine'

module Masqueraide
  module Engine
    class SNLP
      def consume
      end

      def consume_all
      end

      def load
      end

      def make_statement
      end

      def reply(statement, length)
      end

      def dataset
        self
      end
    end
  end
end
