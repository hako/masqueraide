# twitter_ebooks's underlying NLP engine for Masqueraide.
require 'twitter_ebooks'

# Supress Ebooks's log statement.
def log(*args)
end

module Masqueraide
  module Engine
    # Ebooks class that inherits Models from Ebooks::Model
    class Ebooks < Ebooks::Model
      # Supress Ebooks's puts statement. (Use only for debug)
      def puts(p)
      end

      def dataset
        self
      end

      def load(path)
        @model = self.class.superclass.load(path)
      end
    end
  end
end