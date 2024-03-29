# The Standard NLP engine for Masqueraide.

module Masqueraide
  module Engine
    # SNLP (Standard NLP) for Masqueraide.
    # SNLP is a yet to be developed basic example of a custom NLP engine.
    class SNLP < BaseEngine
      # Consume a datasets into a corpus.
      def consume
      end

      # Consume a set of datasets into a corpus.
      def consume_all
      end

      # Load and parse a given dataset. (Must specify what dataset it useful.)
      def load
      end

      # Generate statement based on that corpus.
      def make_statement
      end

      # Say whatever up to a given length.
      def reply(statement, length)
      end

      # Returns the current dataset.
      def dataset
        self
      end
    end
  end
end
