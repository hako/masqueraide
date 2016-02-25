# The Twitter Room is the default room for Masqueraide bots.
# twitter_ebooks handles everything for us, so we just subclass Ebooks::Bot.
# The Twitter Room has this exception, The OAuth dance is not needed. ;)

require 'twitter_ebooks'

module Masqueraide
  module Room
    # The Twitter Room for Masqueraide AI bots.
    class Twitter < Ebooks::Bot
      NAME = 'Twitter'.freeze
      @@ais_in_room = []

      # Name of the room.
      def name
        NAME
      end

      # Fetch an AI by it's name in the room.
      def ai(name)
        ai = @@ais_in_room.select { |ai| ai.username == name }
        ai[0]
      end

      # List all AI's in this room.
      def ais_in_room
        @@ais_in_room.select { |ai| puts ai.username }
      end

      # Class method to list all AI's in this room.
      def self.ais_in_room
        @@ais_in_room.select { |ai| puts ai.username }
      end

      # Set an AI to the room.
      def ai=(ai)
        @ai = ai
        Ebooks::Bot.all << @ai
        @@ais_in_room << @ai
      end

      # A block that configures the current AI in the room.
      def configure(&c)
        self.user = @ai.username
        self.delay_range = 1..6
        yield(self) unless c.nil?
      end

      # On Startup event method. (Must be overriden)
      def on_startup
      end

      # On Message event method. (Must be overriden)
      def on_message(message)
      end

      # On Follow event method. (Must be overriden)
      def on_follow(user)
      end

      # On Mention event method. (Must be overriden)
      def on_mention(tweet)
      end

      # On Timeline event method. (Must be overriden)
      def on_timeline(tweet)
      end

      # On Favorite event method. (Must be overriden)
      def on_favorite(user, tweet)
      end

      # On Retweet event method. (Must be overriden)
      def on_retweet(tweet)
      end
    end
  end
end
