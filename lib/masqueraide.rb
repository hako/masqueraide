require 'masqueraide/version'
require 'masqueraide/ai'
require 'masqueraide/engine/engine'
require 'masqueraide/engine/ebooks'
require 'masqueraide/engine/snlp'
require 'masqueraide/room/twitter'
require 'masqueraide/room/snapchat'
require 'masqueraide/nlp'

module Masqueraide
  ENGINES = {
    twitter_ebooks: Masqueraide::Engine::Ebooks.new,
    snlp: Masqueraide::Engine::SNLP.new
  }.freeze
  ROOMS = {
    twitter: Masqueraide::Room::Twitter,
    snapchat: Masqueraide::Room::Snapchat.new
  }.freeze
end
