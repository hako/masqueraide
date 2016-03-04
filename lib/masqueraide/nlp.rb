# Some NLP helper functions for Masqueraide.

require 'twitter_ebooks'

module Masqueraide
  module NLP
    # Text tokenisation helper.
    def tokenize(text)
      tokens = Ebooks::NLP.tokenize(text)
      tokens
    end

    # TODO, dataset parsing...
    def csv2model(input)
    end
    end
  end
