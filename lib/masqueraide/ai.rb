# This describes a Masqueraide AI.
# It must be able to consume, have an NLP engine, say things, respond to people.
# And be assigned to rooms so they can socialise with people or even other AI's.

require 'openssl'
require 'digest'
require 'colorize'

module Masqueraide
  # AI class for a Masqueraide AI
  class AI
    attr_accessor :ai_name, :username, :room, :id

    # Initalise method for AI class
    #
    # ai_name  = Name of the AI.
    # room     = Room is a supported room by Masqueraide.
    # username = Username of the bot.
    # engine   = Engine is the NLP engine supported by  Masqueraide
    #            Default is :ebooks.
    # &m       = An optional block.

    def initialize(ai_name = nil, room = nil, username = nil, engine = nil, &m)
      @id = 'MAS' << '_' << mid.upcase
      ai_name ||= @id
      engine ||=  :ebooks

      if username.nil? == true && room.nil? == false
        username = room.username.downcase
      else
        username ||= ai_name.downcase
      end

      @ai_name = ai_name
      @engine = engine(engine)
      @username = username.downcase
      @room = assign_room(room) unless room.nil?
      yield(self) unless m.nil?
    end

    # Learns from a dataset, creates and uses a model internally.
    def learn_from_dataset(path)
      # If array use consume_all.
      if (File.exist? path) == false
        raise 'FileNotFoundError: The path "' + path + '" does not exist'
      end
      return @engine.consume_all path if (path.respond_to? 'each') == true
      @engine.consume path
    end

    # Is our AI assigned a room?
    def assigned?
      return true unless @room.nil?
      false
    end

    # Loads an already created dataset from a path.
    def load_dataset(path)
      if (File.exist? path) == false
        raise 'FileNotFoundError: The path "' + path + '" does not exist'
      end
      return @engine.load path if (path.respond_to? 'each') == true
      @engine.load path
    end

    # Says something.
    def say(length)
      if length.integer? == false
        raise 'ArgumentError: "' + length.to_s + '" is not an integer.'
      end
      @engine.make_statement(length)
    end

    # Returns the dataset.
    def dataset
      @engine.dataset
    end

    # Replies to the person.
    def reply(reply, length)
      if length.integer? == false
        raise 'ArgumentError: "' + length.to_s + '" is not an integer.'
      end
      @engine.make_response(reply, length)
    end

    # Assigns an AI to a social media room.
    # Parameter r must be a symbol.
    # See Masqueraide::ROOMS for available rooms.
    def assign_room(r)
      if r.class.to_s.byteslice(0, 17) == Masqueraide::Room.to_s
        @room = r
        @room.ai = self
        return @room
      elsif r.class.superclass.to_s.byteslice(0, 17) == Masqueraide::Room.to_s
        @room = r
        @room.ai = self
        return @room
      elsif Symbol.all_symbols.include? r.to_sym
        result = ROOMS.key?(r.to_sym)
        if result == false
          raise 'RoomNotFoundException: ' + 'Room not found for: ' + r.to_s
        else
          @room = ROOMS[r.to_sym]
          # Only applies to a special case like twitter.
          @room = @room.new(@username) if @room == Masqueraide::Room::Twitter
          @room.ai = self
          return @room
        end
      end
    end

    # Starts the AI. Let's Dance.
    def start(fancy = false, commentary = false)
      if fancy == true

        puts "
        .ad88ba.
       .ad8888888a.
      d8``988P``988b
      9b,,d88,,,d8888
     d888P~~9888888b'
     d888   '88KHW8P
     `dP'     9888P

   " + 'M A S Q U E R ' + 'A I'.white + " D E\n" + phrases + "\n"
        puts ''
        puts '----------------------------------------'

      else
        sleep 1
        puts 'M A S Q U E R A I D E'.bold
        puts ''
        puts 'Masqueraide has started.'

      end

      # TODO: Might have a threading issue here...
      if (@room.respond_to? 'each') == true
        @room.each do |b|
          b.prepare
          b.start
        end
      end

      if commentary == true
        if @room.name == 'Twitter'
          puts @ai_name + " (@#{username})".cyan.bold + ' enters the ' + @room.name.downcase + ' room...'
        end
        sleep 2
        puts @ai_name + ' puts on a mask with id ' + @id + ' and gets ready...'
        sleep 1
        @room.prepare
        puts @ai_name.white + ':'.white + ' Ready.'
        sleep 0.5
        puts 'Let the Masqueraide begin.'.bold
        sleep 1
        puts @ai_name.white + ' is now socialising in the ' + @room.name.downcase + ' room.'
      else
        @room.prepare
        sleep 1
        puts @ai_name.white + ' is now masquerading as a human in the ' + @room.name.downcase + ' room.'
      end
      @room.start
    end

    private

    # Returns any engine in ENGINES.
    def engine(engine)
      result = ENGINES.key?(engine.to_sym)
      if result == false
        raise 'EngineNotFoundException: ' + 'Engine not found for: ' + engine.to_s
      else
        return ENGINES[engine]
      end
    end

    # Random Masqueraide launch phrases.
    def phrases
      quote = ['  Let the dance begin.', '     Human or AI?', "     Let's dance."]
      quote[Random.rand(0...quote.length)]
    end

    # Defaults to a given mid if none is available.
    def mid
      id = OpenSSL::Random.random_bytes(8).to_str
      Digest.hexencode(id)
    end
    alias dance start
  end
end
