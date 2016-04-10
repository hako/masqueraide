# The Ebooks engine is based on the twitter_ebooks model.
# this engine serves as the default NLP engine for Masqueraide.
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
      
      # Returns the current dataset.
      def dataset
        self
      end
      
      # Loads an already created dataset from a path.
      # Calls the superclass Ebooks::Model to load it.
      def load(path)
        @model = self.class.superclass.load(path)
      end
    end
  end
end