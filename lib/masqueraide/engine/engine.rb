# BaseEngine is a good starting point for your own NLP engine 
# to work with Masqueraide.

# Custom engines must be a module of 'Masqueraide::Engine' 
# and sublcass BaseEngine.

module Masqueraide
  module Engine
    class BaseEngine
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

    	def dataset
    		self
    	end
    end
  end
end