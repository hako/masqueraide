# twitter_ebooks's underlying NLP engine for Masqueraide.
require 'twitter_ebooks'

# Supress Ebook's log statement. (Use only for debug)
def log(*args)
end

module Masqueraide
	module Engine
		class Ebooks < Ebooks::Model
			# Supress Ebook's puts statement. (Use only for debug)
			def puts(p)
			end
		end
	end
end