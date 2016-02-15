require "masqueraide/version"
require "masqueraide/ai"
require "masqueraide/engine/ebooks"
require "masqueraide/engine/nlp"
require "masqueraide/room/twitter"
require "masqueraide/room/snapchat"

module Masqueraide
	ENGINES = {
		:twitter_ebooks => Masqueraide::Engine::Ebooks.new,
		:snlp => Masqueraide::Engine::NLP.new,
	}
	ROOMS = {
		:twitter => Masqueraide::Room::Twitter,
		:snapchat => Masqueraide::Room::Snapchat.new,
	}
end