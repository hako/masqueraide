require 'masqueraide'

describe 'Masqueraide NLP' do
  describe 'NLP Utilities' do
    it 'tokenizes words correctly' do
      text = "the quick brown fox jumps over the lazy dog."
      tokenized_text = Masqueraide::NLP.tokenize(text)
      expect(tokenized_text).to eq ["the", "quick", "brown", "fox", "jumps", "over", "the", "lazy", "dog."]
    end
    
    it 'estimates typing delay correctly' do
      text = "the quick brown fox jumps over the lazy dog."
      delay = Masqueraide::NLP.typing_delay(text)
      expect(delay).to eq 8.018086535868424
    end
    
    it 'estimates typing delay correctly with the same repeated characters' do
      text = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      delay = Masqueraide::NLP.typing_delay(text)
      expect(delay).to eq 1.0
    end
  end
end
