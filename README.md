```
											         .,ad88888ba,.
											     .,ad8888888888888a,
											    d8P"""98888P"""98888b,
											    9b    d8888,    `9888B
											  ,d88aaa8888888b,,,d888P'
											 d8888888888888888888888b
											d888888P""98888888888888P
											88888P'    9888888888888
											`98P'       9888888888P'
											             `"9888P"'
											                `"'
```

<h3 align="center">
  <code>M A S Q U E R <b>A I</b> D E</code>
  <br><br>
</h3>

# Masqueraide [![Build Status](https://travis-ci.com/hako/masqueraide.svg?token=bJfam1KHVz8SidpzxUbF&branch=master)](https://travis-ci.com/hako/masqueraide)

Masqueraide is an AI/Bot library that is designed to run on social networks. Masqueraide works by having two concepts called **'Rooms'** and **'Engines'**. Social networks are 'Rooms', and the underlying NLP (Natrual Language Processing) algorithms are the 'Engines'.

In the near future, Masqueraide will have plugin support, more NLP engines and more social networks.

This library was part of a group project to make as if the AI/Bot is able to pass the [Turing Test](https://en.wikipedia.org/wiki/Turing_test) proposed by Alan Turing in 1950.

By default, Masqueraide utilises & builds on top of the excellent [twitter_ebooks](https://github.com/mispy/twitter_ebooks) framework by [@mispy](http://github.com/mispy).


## Requirements

+ ruby
+ bundler
+ aspell (This might change in the future.)

## Installation

If you're on Linux, first get masqueraide's depedencies:

```sh
[sudo] apt-get update -qq
[sudo] apt-get install -qq aspell libaspell-dev aspell-en aspell-el aspell-nl
# Assuming that ruby is installed
[sudo] gem install bundler
```

Then, if you have bundler installed, run:

`git clone https://github.com/hako/masqueraide`

And then execute:

    $ bundle
	
Or

Add this line to your application's Gemfile:

```ruby
gem 'masqueraide'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install masqueraide

## Usage

The following example below is for a standard twitter bot.

There are two ways to dance:

A block.

```ruby
require 'masqueraide'

# Create a new bot with a name.
bot = Masqueraide::AI.new('Bot')

# Before your bot can generate responses, it needs a dataset to learn from.
bot.learn_from_dataset path_to_dataset

# You can assign your bot a room, by default the 'Twitter Room' is selected.
bot.assign_room :twitter

# An example Bot configuration.
# This configures the bot's actions for the chosen room.
# In this case, this is the configuration for the 'Twitter Room'
bot.room.configure do |config|
  config.consumer_key = ''
  config.consumer_secret = ''
  config.access_token = ''
  config.access_token_secret = ''
end

# Dance. (Starts the bot)
bot.dance
```

A class.

```ruby
require 'masqueraide'

# An example Bot class.
# This configures your bot's actions in the 'Twitter Room'
class BotClass < Masqueraide::Room::Twitter
  def configure
    self.consumer_key = ''
    self.consumer_secret = ''
    self.access_token = ''
    self.access_token_secret = ''
  end

  def on_startup
    scheduler.every '1m' do
      tweet(ai('twitter_handle').say(130))
    end
  end
end

# Create a new bot for the chosen room, in this case the 'Twitter Room'
# Each room may require additional parameters. The bot is tied a twitter handle.
bot = Masqueraide::AI.new('Bot', Bot.new('twitter_handle'))

# Before your bot can generate responses, it needs a dataset to learn from.
bot.learn_from_dataset path_to_dataset

# Dance. (Starts the bot)
bot.dance
```

## Supported Social Networks

Masqueraide supports the current social networks below:

+ **Twitter** (By using twitter_ebooks)
+ **Snapchat**
+ **Your own????**

Some social networks that _might_ be supported in the future depending on the userbase.

+ **Facebook Messenger**
+ **Kik**
+ **Instagram**

You can create your own 'room' by creating a class under `Masqueraide::Room` and assigning your AI to that room.

## Examples

Example bots are in the [examples](https://github.com/hako/masqueraide/tree/master/examples/drbrianmitchell) folder.
#### [Dr Brian Mitchell - Health Doctor Bot](https://github.com/hako/masqueraide/tree/master/examples/drbrianmitchell)

## NLP

NLP related helper functions are available under `Masqueraide::NLP`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/hako/masqueraide/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
