#!/usr/bin/ruby

# Dr. Brian Mitchell is an AI social Twitterbot that 'Masqueraide's' as a human
# to chat with users about their health problems.

require 'classifier-reborn'
require 'dotenv'
require 'ffi/aspell'
require 'masqueraide'
require 'nameable'

require './corpuses/training/data.rb'

# The Brian class, for the Dr. Brian Mitchell Twitter account.
class Brian < Masqueraide::Room::Twitter
  attr_accessor :sentiment
  def configure
    # In order for Brian to diagnose patients on Twitter,
    # you must set the following as environment variables or in a .env file.
    #
    # CONSUMER_KEY=XXXXXXXXXXXXXXXXXXXXXX
    # CONSUMER_SECRET=XXXXXXXXXXXXXXXXXXXXXX
    # ACCESS_TOKEN=XXXXXXXXXXXXXXXXXXXXXX
    # ACCESS_TOKEN_SECRET=XXXXXXXXXXXXXXXXXXXXXX
    #
    # Where XXXXXXXXXXXXXXXXXXXXXX is your Twitter API key for the account.
    # See https://apps.twitter.com to sign in and create an App.

    # Loads environment variables from a .env file.
    Dotenv.load

    # Set the API keys from environment variables.
    self.consumer_key = ENV['CONSUMER_KEY']
    self.consumer_secret = ENV['CONSUMER_SECRET']
    self.access_token = ENV['ACCESS_TOKEN']
    self.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
    self.delay_range = 1..120
  end

  # Do something once Brian has finished starting up.
  def on_startup
    sentiment_corpus = File.read('corpuses/training/training.msqrd')
    @sentiment = Marshal.load sentiment_corpus
    log "Loaded training data 📚"
    log 'Ready to start diagnosing patients!'
    log " 🏥 The Doctor is in! 🏥 "
  end

  # Gives context to the conversation.
  # Uses their real name.
  def contextualise_greeting(username)
    customised_greeting = []
    GREETINGS['data'].each do |greeting|
      greeting = greeting.gsub('*', username)
      @sentiment.train(:greeting, greeting)
      customised_greeting << greeting
    end
    customised_greeting
  end

  # Do something if someone mentions (@mentions) Brian.
  def on_mention(twt)
    Random.new_seed

    # We load our bot here.
    bot = ai('drbmitchellphd')

    # The replying dataset.
    bot.learn_from_dataset 'corpuses/doctor_tweet_corpus.txt'

    # Delay typing to act like a human is thinking what to say.
    # Produce a mistake rate between 0.1 and 1.
    sleep Masqueraide::NLP.typing_delay(twt.text)

    # Check if the text is unintelligible before responding
    # for enquiries.
    if Masqueraide::NLP.unintelligible twt.text
      rand = Random.new.rand 0.1..1
      unsure_response = []
      # Choose a random unsure sentence from the markov chain.
      if rand > 0.5
        unsure_sentences = []
        while unsure_sentences.length != 10
          sentence = bot.reply(twt.text, 140)
          if sentiment.classify_with_score(sentence)[0].to_sym == :unsure
            unsure_sentences << sentence
          end
        end
      else
        # Or use predefined corpus.
        # Read the DM corpus and produce an unsure response.
        unsure_response = DR_UNSURE['data'].select
      end
      unsure_response = unsure_response.sample
      sleep Masqueraide::NLP.typing_delay(unsure_response)
      reply(dm, unsure_response)
      return
    end

    real_reply = bot.reply(twt.text, 140)

    # Delay based on how long it takes to type the message. and add 1 to 60.
    # Does not need to reply instantly.
    sleep Masqueraide::NLP.typing_delay(real_reply) + (Random.new.rand 1..30)
    reply(twt, brian_reply)
  end

  # Optionally formalises the user Dr. Brian Mitchell is talking to.
  # Eg. John Doe -> Mr Doe
  #     Jane Doe -> Ms Doe
  def formalise_username(n)
    name = Nameable::Latin.new.parse(n)
    if !name.last.nil?
      if name.gender == :female
        'Ms ' + name.last
      else
        'Mr ' + name.last
      end
    else
      name.first
    end
  end

  # Do something if someone sends a private direct message to Brian.
  # (Brian is more likely to answer through a DM than regular tweets)
  def on_message(dm)
    Random.new_seed
    # We load our bot here.
    bot = ai('drbmitchellphd')

    # The replying dataset.
    bot.learn_from_dataset 'corpuses/doctor_dm_corpus.txt'

    # Delay typing to act like a human is thinking what to say.
    # Produce a mistake rate between 0.1 and 1.
    sleep Masqueraide::NLP.typing_delay(dm.text)

    # Check if the text is unintelligible before responding
    # for enquiries.
    if Masqueraide::NLP.unintelligible? dm.text
      rand = Random.new.rand 0.1..1
      unsure_response = ''
      # Choose a random unsure sentence from the markov chain.
      if rand > 0.5
        unsure_sentences = []
        while unsure_sentences.length != 10
          sentence = bot.reply(dm.text, 140)
          if sentiment.classify_with_score(sentence)[0].to_sym == :unsure
            unsure_sentences << sentence
          end
        end
        unsure_response = unsure_sentences.sample
      else
        # Or use predefined corpus.
        # Read the DM corpus and produce an unsure response.
        unsure_response = DR_UNSURE['data'].sample
      end
      sleep Masqueraide::NLP.typing_delay(unsure_response)
      reply(dm, unsure_response)
      return
    end

    # Check to see what the sentiment is.
    user_sentiment = @sentiment.classify_with_score(dm.text)
    log 'User sentiment: ' + user_sentiment[0].to_s + ', Confidence: ' + user_sentiment[1].to_s

    # Deliberately produce a mistake based on random rate.
    rate = (Random.new.rand 0.1..1)
    log 'Mistake rate: ' + rate.to_s

    final_sentiment = user_sentiment[0].to_sym

    # Produce a mistake if the rate is greater than the threshold value...
    if rate > 0.83
      log 'Deliberately going to produce a mistake!'

      # Do something based on what type of sentiment it is.
      # We also have to do some more NLP to suggest what issue
      # The patient has. Reply once it is ready to answer.
      real_reply = case final_sentiment
                   when :greeting
                     contextualise_greeting(formalise_username(dm.sender.name)).sample
                   # when :secondary_greeting
                   #   # Do something here....
                   # when :answer
                   #   # Do something here....
                   # when :question
                   #   # Do something here....
                   # when :thanks
                   #   # Do something here....
                   # when :unsure
                   #   # Do something here....
                   # when :positive
                   #   # Do something here....
                   # when :negative
                   else
                     bot.reply(dm.text, 140)
                   end

      mistake_reply = Masqueraide::NLP.produce_mistake(real_reply)
      correction = mistake_reply['correction']

      # Tweet the mistake to the human...
      reply(dm, mistake_reply['text'])
      sleep Random.new.rand 4..10

      # ...then tweet the correction.
      if mistake_reply['mistakes'] == true
        sleep Masqueraide::NLP.typing_delay(correction)
        reply(dm, '*' + correction)
      end
    else
      # ...Or just send a normal direct message.
      log 'Producing a normal direct message.'

      # Do something based on what type of sentiment it is.
      # We also have to do some more NLP to suggest what issue
      # The patient has. Reply once it is ready to answer.
      real_reply = case final_sentiment
                   when :greeting
                     contextualise_greeting(formalise_username(dm.sender.name)).sample
                   # when :secondary_greeting
                   #   # Do something here....
                   # when :answer
                   #   # Do something here....
                   # when :question
                   #   # Do something here....
                   # when :thanks
                   #   # Do something here....
                   # when :unsure
                   #   # Do something here....
                   # when :positive
                   #   # Do something here....
                   # when :negative
                   else
                     bot.reply(dm.text, 140)
                   end

      # Delay based on how long it takes to type the message.
      # (Brian should not reply instantly.)
      sleep Masqueraide::NLP.typing_delay(real_reply) + (Random.new.rand 1..30)
      reply(dm, real_reply)
    end
  end
end

# Start the Twitterbot. and catch a CNTRL-C.
begin
  bot = Masqueraide::AI.new('Dr. Brian Mitchell', Brian.new('drbmitchellphd'))
  bot.room.logging = true
  bot.dance true, true
rescue SystemExit, Interrupt
  puts "\nShutting down chat session..."
rescue StandardError => e
  # Print the exception.
  puts e
end
