# Some NLP helper functions for Masqueraide.

require 'twitter_ebooks'
require 'ffi/aspell'

module Masqueraide
  # Masqueraide::NLP module is used for custom NLP functions and algorithms
  # helping to power Masqueraide.
  module NLP
    # Cartesian QWERTY keyboard map.
    QUERTYMAP = {
      'q' => { 'y' => 0, 'x' => 0 },
      'w' => { 'y' => 0, 'x' => 1 },
      'e' => { 'y' => 0, 'x' => 2 },
      'r' => { 'y' => 0, 'x' => 3 },
      't' => { 'y' => 0, 'x' => 4 },
      'y' => { 'y' => 0, 'x' => 5 },
      'u' => { 'y' => 0, 'x' => 6 },
      'i' => { 'y' => 0, 'x' => 7 },
      'o' => { 'y' => 0, 'x' => 8 },
      'p' => { 'y' => 0, 'x' => 9 },

      'a' => { 'y' => 1, 'x' => 0 },
      's' => { 'y' => 1, 'x' => 1 },
      'd' => { 'y' => 1, 'x' => 2 },
      'f' => { 'y' => 1, 'x' => 3 },
      'g' => { 'y' => 1, 'x' => 4 },
      'h' => { 'y' => 1, 'x' => 5 },
      'j' => { 'y' => 1, 'x' => 6 },
      'k' => { 'y' => 1, 'x' => 7 },
      'l' => { 'y' => 1, 'x' => 8 },

      'z' => { 'y' => 2, 'x' => 0 },
      'x' => { 'y' => 2, 'x' => 1 },
      'c' => { 'y' => 2, 'x' => 2 },
      'v' => { 'y' => 2, 'x' => 3 },
      'b' => { 'y' => 2, 'x' => 4 },
      'n' => { 'y' => 2, 'x' => 5 },
      'm' => { 'y' => 2, 'x' => 6 },

      ',' => { 'y' => 2, 'x' => 7 },
      '<' => { 'y' => 2, 'x' => 7 },
      '.' => { 'y' => 2, 'x' => 8 },
      '>' => { 'y' => 2, 'x' => 8 },
      '/' => { 'y' => 2, 'x' => 9 },
      '?' => { 'y' => 2, 'x' => 9 },

      '`' => { 'y' => -1, 'x' => -1 },
      '~' => { 'y' => -1, 'x' => -1 },
      '!' => { 'y' => -1, 'x' => 0 },
      '@' => { 'y' => -1, 'x' => 1 },
      '#' => { 'y' => -1, 'x' => 2 },
      '$' => { 'y' => -1, 'x' => 3 },
      '%' => { 'y' => -1, 'x' => 4 },
      '^' => { 'y' => -1, 'x' => 5 },
      '&' => { 'y' => -1, 'x' => 6 },
      '*' => { 'y' => -1, 'x' => 7 },

      '1' => { 'y' => -1, 'x' => 0 },
      '2' => { 'y' => -1, 'x' => 1 },
      '3' => { 'y' => -1, 'x' => 2 },
      '4' => { 'y' => -1, 'x' => 3 },
      '5' => { 'y' => -1, 'x' => 4 },
      '6' => { 'y' => -1, 'x' => 5 },
      '7' => { 'y' => -1, 'x' => 6 },
      '8' => { 'y' => -1, 'x' => 7 },
      '9' => { 'y' => -1, 'x' => 8 },
      '0' => { 'y' => -1, 'x' => 9 },

      '(' => { 'y' => -1, 'x' => 8 },
      ')' => { 'y' => -1, 'x' => 9 },
      '-' => { 'y' => -1, 'x' => 10 },
      '_' => { 'y' => -1, 'x' => 10 },
      '=' => { 'y' => -1, 'x' => 11 },
      '+' => { 'y' => -1, 'x' => 11 },

      "\r" => { 'y' => 0, 'x' => -1 },
      '[' => { 'y' => 0, 'x' => 10 },
      '{' => { 'y' => 0, 'x' => 10 },
      ']' => { 'y' => 0, 'x' => 11 },
      '}' => { 'y' => 0, 'x' => 11 },
      '|' => { 'y' => 0, 'x' => 12 },
      '\\' => { 'y' => 0, 'x' => 12 },

      ':' => { 'y' => 1, 'x' => 9 },
      ';' => { 'y' => 1, 'x' => 9 },
      '\'' => { 'y' => 1, 'x' => 10 },
      '"' => { 'y' => 1, 'x' => 10 },
      "\n" => { 'y' => 1, 'x' => 11 },

      ' ' => { 'y' => 3, 'x' => 4 }
    }.freeze

    # Text tokenisation helper.
    def self.tokenize(text)
      tokens = Ebooks::NLP.tokenize(text)
      tokens
    end

    # TODO: Fix this:
    # Deliberately produces a mistake in a sentence.
    def self.produce_mistake(text)
      tokens = tokenize text
      tokens_index = Random.new.rand 0..tokens.length - 1
      correct_word = tokens[tokens_index]

      selected_word_index = Random.new.rand 0..correct_word.length - 1
      misspelled_char = correct_word[selected_word_index].succ
      misspelled_word = correct_word
      misspelled_word[selected_word_index] = misspelled_char

      tokens[tokens_index] = misspelled_word

      correct = tokenize text
      true_word = correct[tokens_index]

      result = { 'text' => tokens.join(' '), 'correction' => true_word, 'mistakes' => true, 'mistake' => misspelled_word }
      result
    end

    # TODO, csv dataset parsing...
    def self.csv2model(_input)
    end

    # Determines if the given text is unreadable.
    def self.unintelligible?(txt)
      speller = FFI::Aspell::Speller.new
      errors = 0
      txt = txt.gsub(/[^a-z0-9\s]/i, '')
      tokens = tokenize txt
      tokens.each do |d|
        errors += 1 if speller.correct?(d) == false && d != 'ok'
      end
      return true if errors > 0 && tokens.length == errors
      false
    end

    # An typing delay algorithm based on the length of the sentence and the words per minute typed.
    # The rate at which the bot types at can be changed.
    def self.typing_delay(words, wpm = 23)
      w = 0
      travelled = 0
      mistakes = 0
      return 0 if words.empty?
      word = words.downcase
      while w + 1 != words.length
        travelled += key_distance(word[w], word[w + 1])
        w += 1
      end
      spelling = FFI::Aspell::Speller.new('en_GB')
      words = words.split
      words.each { |wrd| mistakes += 1 unless spelling.correct?(wrd) }
      (travelled / wpm) + mistakes
    end

    # Used for calculating the euclidian distance between c1 and c2 on a keyboard or soft keyboard.
    def self.key_distance(c1, c2)
      a = (QUERTYMAP[c1]['x'] - QUERTYMAP[c2]['x'])**2
      b = (QUERTYMAP[c1]['y'] - QUERTYMAP[c2]['y'])**2
      Math.sqrt(a + b)
    end

    private_class_method :key_distance
  end
end
