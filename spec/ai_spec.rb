require 'masqueraide'

describe 'Masqueraide AI' do
  describe 'AI attributes' do
    it 'is in the correct format' do
      expect(Masqueraide::AI.new('TestBot').id[0..3]).to eq 'MAS_'
    end
    it 'is the correct length' do
      expect(Masqueraide::AI.new('TestBot').id.length).to eq 20
    end
    it 'is assigned the correct name' do
      expect(Masqueraide::AI.new('TestBot').ai_name).to eq 'TestBot'
    end
  end
  describe 'AI Rooms' do
    it 'is not assigned to a room' do
      testbot = Masqueraide::AI.new('TestBot')
      expect(testbot.assigned?).to eq false
    end
    it 'is assigned to a room' do
      testbot = Masqueraide::AI.new('TestBot')
      testbot.assign_room :twitter
      expect(testbot.assigned?).to eq true
    end
  end
  describe 'AI statements and responses' do
    it 'can generate a statement' do
      testbot = Masqueraide::AI.new('TestBot')
      testbot.learn_from_dataset "spec/test_dataset/dataset_1.txt"
      expect(testbot.say(140)).to eq "the quick brown fox jumps over the lazy dog"
    end
    it 'can generate a response' do
      testbot = Masqueraide::AI.new('TestBot')
      testbot.learn_from_dataset "spec/test_dataset/dataset_2.txt"
      expect(testbot.reply("test response",140).length).not_to eq 0
    end
    it 'can produce a response that is less than or equal to 140 characters' do
      testbot = Masqueraide::AI.new('TestBot')
      testbot.learn_from_dataset "spec/test_dataset/dataset_2.txt"
      expect(testbot.reply("test response",140).length).to be <= 140
    end
  end
end
