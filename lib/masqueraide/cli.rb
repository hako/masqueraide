require 'masqueraide'
require 'masqueraide/server'
require 'twitter_ebooks'
require 'thor'

# Commands for the Twitter Room.
module Commands
  # Twitter Subcommand class.
  class Twitter < Thor
    package_name 'Masqueraide Twitter'
    desc 'archive [USERNAME, PATH]', "Consumes a Twitter user's tweets."
    def archive(username, path)
      if username.nil?
        puts 'username is empty.'
        puts :desc
        exit 1
      end
      puts 'Archiving @' + username + "'s tweets using twitter_ebooks..."
      begin
         Ebooks::Archive.new(username, path + '.json').sync
       rescue StandardError => e
         puts 'Unable to archive @' + username + "'s tweets."
         puts 'Please check that the path "' + path + '" exists.'
         puts 'Reason: ' + e.to_s
         exit 1
       end
      puts 'Successfully saved archived tweets as "' + path + '.json"'
    end
    desc 'consume [NAME]', "Consumes a Twitter user's tweets to a model."
    def consume(path)
      if path.nil?
        puts 'path does not exist.'
        puts :desc
        exit 1
      end
      puts 'Consuming ' + path + "'s tweets using twitter_ebooks..."
      begin
         path_name = File.basename(path)
         model_name = path_name.split('.')[0..-2].join('.')
         Ebooks::Model.consume(path).save(model_name + '.model')
       rescue StandardError => e
         puts 'Unable to consume data from path ' + path
         puts 'Please check that the path "' + path + '" exists.'
         puts 'Reason: ' + e.to_s
         exit 1
       end
      puts 'Successfully consumed tweets as "' + model_name + '.model' + '"'
    end
  end
end

# Main CLI module.
module Masqueraide
  # CLI class for main commands.
  class CLI < Thor
    if ARGV.empty?
      puts "
       .ad88ba.
      .ad8888888a.
     d8``988P``988b
     9b,,d88,,,d8888
    d888P~~9888888b'
    d888   '88KHW8P
    `dP'     9888P

- M A S Q U E R A I D E -
         #{Masqueraide::VERSION}
  "
    end
    package_name 'Masqueraide'
    desc 'load [BOT]', 'Load and run a bot into Masqueraide.'
    def load(bot)
      Kernel.load bot
    end
    desc 'serve', 'Starts the builtin Masqueraide server.'
    def serve
      Masqueraide::Server.run!
    end
    desc 'twitter [SUBCOMMAND]', 'Commands related to twitter.'
    subcommand 'twitter', Commands::Twitter
  end
end
