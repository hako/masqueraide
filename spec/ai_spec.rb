require 'masqueraide'

describe 'Masqueraide AI' do
  describe 'AI attributes' do
    it 'is in the correct format' do
      expect(Masqueraide::AI.new('Bot').id[0..3]).to eq 'MAS_'
    end
    it 'is the correct length' do
      expect(Masqueraide::AI.new('Bot').id.length).to eq 20
    end
    it 'is assigned the correct name' do
      expect(Masqueraide::AI.new('Bot').ai_name).to eq 'Bot'
    end
  end
end
