require 'masqueraide'

describe 'Masqueraide NLP' do
  describe 'NLP Utilities' do
    it 'tokenizes words correctly' do
      text = 'the quick brown fox jumps over the lazy dog.'
      tokenized_text = Masqueraide::NLP.tokenize(text)
      expect(tokenized_text).to eq ['the', 'quick', 'brown', 'fox', 'jumps', 'over', 'the', 'lazy', 'dog.']
    end

    it 'estimates typing delay correctly' do
      text = 'the quick brown fox jumps over the lazy dog.'
      delay = Masqueraide::NLP.typing_delay(text)
      expect(delay).to eq 8.018086535868424
    end

    it 'estimates typing delay correctly with the same repeated characters' do
      text = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
      delay = Masqueraide::NLP.typing_delay(text)
      expect(delay).to eq 1.0
    end

    it 'estimates typing delay correctly with different characters' do
      text = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      delay = Masqueraide::NLP.typing_delay(text)
      expect(delay).to eq 3.726906294819124
    end

    it 'deliberately produces a mistake from a sentence' do
      text = 'the quick brown fox jumps over the lazy dog.'
      result = Masqueraide::NLP.produce_mistake(text)
      mistake = result['text']
      expect(mistake).not_to eq text
    end

    it 'knows what text is unintelligible.' do
      text = 'abcdefghijklmnopqrstuvwxyz'
      result = Masqueraide::NLP.unintelligible?(text)
      expect(result).to eq true
    end

    it 'knows what text is intelligible.' do
      text = 'the quick brown fox jumps over the lazy dog.'
      result = Masqueraide::NLP.unintelligible?(text)
      expect(result).to eq false
    end
  end
end
