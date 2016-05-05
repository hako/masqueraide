#!/usr/bin/ruby

# Dr. Brian Mitchell is an AI socialbot that 'Masquerades' (or Masqueraides) as a human
# to chat with users about their health problems.

require 'classifier-reborn'
require 'dotenv'
require 'ffi/aspell'
require 'masqueraide'
require 'nameable'
require 'engtagger'

# Datasets
require './corpuses/training/conversation.rb'
require './corpuses/training/datasets/cough.rb'
require './corpuses/training/datasets/flu.rb'

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

    # Set the API keys from the environment variables.
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
    @threshold = 0.15
    @value = 0
  end

  # Gives context to the conversation. Uses their real name.
  def contextualise_greeting(username)
    customised_greeting = []
    GREETINGS['data'].each do |greeting|
      greeting = greeting.gsub('*', username)
      @sentiment.train(:greeting, greeting)
      customised_greeting << greeting
    end
    customised_greeting
  end

  # Dr. Brian Mitchell diagnoses patients by taking a string of text and assigning a score.
  # The score is assigned if a particular keyword matches a set of symptoms in the conditions database.

  # If the score reaches the threshold value,
  # then Dr. Brian Mitchell will conclude his findings and tell you the diagnosis.
  def diagnose(text)
    # Tag important words from a sentence to start the diagnosis.
    tag = EngTagger.new
    diagnosis = tag.get_words(text).keys
    extracted = diagnosis
    diagnosis.each { |d| diagnosis = d.split(' ').uniq.join(' ') if d.include?(' ') }
    diagnosis = { 'diagnosis' => diagnosis, 'keywords' => extracted }

    # Diagnose illness by counting relevant keywords in the FLU and COUGH datasets.
    FLU['symptoms'].map do |f|
      FLU['score'] += 1 if diagnosis['keywords'].include?(f)
    end

    COUGH['symptoms'].map do |c|
      COUGH['score'] += 1 if diagnosis['keywords'].include?(c)
    end

    # Calculate condition probability.
    fluprob = FLU['score'].to_f / FLU['symptoms'].length.to_f
    coughprob = COUGH['score'].to_f / COUGH['symptoms'].length.to_f
    probabilities = { 'the flu' => fluprob, 'a cough' => coughprob }
    likely = probabilities.max_by { |_k, v| v }
    @value += likely[1]
    data = { 'the flu' => FLU, 'a cough' => COUGH }

    { 'likely_condition' => likely[0], 'likelyhood' => likely[1], 'condition_data' => data[likely[0]] }
  end

  # Do something if someone tweets to Dr. Brian Mitchell publicly.

  # Note: We cannot diagnose patients publicly, due to legal reasons.
  # But we can have a conversation though! :P
  # If the user asks a question that is sensitive like, "I feel sick doctor" or "I sprained my knee today"
  # We must ask them to DM us first before we go further.
  # Once we say that, we should not accept any more tweets from this patient for more than 8 hours.
  # Only reply to their DM's from now on. We can still like or retweet their tweets if something they said is interesting to Dr Mitchell.
  def on_mention(twt)
    Random.new_seed

    # We load our bot here.
    bot = ai('drbmitchellphd')

    # The replying dataset.
    bot.learn_from_dataset 'corpuses/doctor_tweet_corpus.txt'

    # Delay typing to act like a human is thinking what to say.
    # Produce a mistake rate between 0.1 and 1.
    sleep Masqueraide::NLP.typing_delay(twt.text)

    # Check if the text is unintelligible before responding to the patient.
    if Masqueraide::NLP.unintelligible? twt.text
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
        # Or use a predefined corpus.
        # Read the DM corpus and produce an unsure response.
        unsure_response = DR_UNSURE['data'].select
      end
      unsure_response = unsure_response.sample
      sleep Masqueraide::NLP.typing_delay(unsure_response) + (Random.new.rand 1..15)
      reply(twt, unsure_response)
      return
    end

    # TODO: sentiment on public tweets.

    # We must identify between :question and :conversation tweets.
    # Continue the conversation publicly, but once offered to DM privately, don't talk to the person for (Time.now + 8 hours)
    # The doctor is busy.

    real_reply = bot.reply(twt.text, 140)

    # Delay based on how long it takes to type the message. and add 1 to 30.
    # Dr. Brian Mitchell does not need to reply instantly.
    sleep Masqueraide::NLP.typing_delay(real_reply) + (Random.new.rand 1..30)
    reply(twt, brian_reply)
  end

  # Optionally formalises the name Dr. Brian Mitchell is talking to.
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

  # Generate a diagnosis reply based on the results and the person we are talking to.
  def formulate_diagnose_reply(results, username)
    if @value > @threshold
      customised_diagnose = []
      DR_DIAGNOSE_RESULTS['data'].each do |diagnose|
        diagnose = diagnose.gsub('*', username)
        diagnose = diagnose.gsub('@', results['likely_condition'])
        diagnose = diagnose.gsub('%', results['condition_data']['treatment'].sample)
        diagnose = diagnose.gsub('~', results['condition_data']['worse_conditions'].sample)
        diagnose = diagnose.gsub('#', results['condition_data']['possible_conditions'].sample)
        customised_diagnose << diagnose
      end
      return customised_diagnose
    else
      customised_diagnose = []
      DR_DIAGNOSE['data'].each do |diagnose|
        diagnose = diagnose.gsub('*', username)
        diagnose = diagnose.gsub('@', results['likely_condition'])
        customised_diagnose << diagnose
      end
    end
  end

  # Do something if someone sends a direct message (DM) to Dr. Brian Mitchell.
  # (Dr. Mitchell is more likely to answer through a DM than regular tweets.)
  def on_message(dm)
    Random.new_seed
    # We load our bot here.
    bot = ai('drbmitchellphd')

    # The replying dataset for our DMs.
    bot.learn_from_dataset 'corpuses/doctor_dm_corpus.txt'

    # Delay typing to act like a human is thinking what to say.
    # Produce a mistake rate between 0.1 and 1.
    sleep Masqueraide::NLP.typing_delay(dm.text)

    # Check if the text is unintelligible before responding to the patient.
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
        # Or use a predefined corpus.
        # Read the DM corpus and produce an unsure response.
        unsure_response = DR_UNSURE['data'].sample
      end
      sleep Masqueraide::NLP.typing_delay(unsure_response) + (Random.new.rand 8..30)
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

    # Produce a mistake if the rate is greater than the magic threshold value 0.83.
    if rate > 0.83
      log 'Deliberately going to produce a mistake!'

      # Do something based on what type of sentiment it is.
      # We also have to do some more NLP to suggest what issue The patient has.
      # Reply once it is ready to answer.
      real_reply = case final_sentiment
                   when :greeting
                     contextualise_greeting(formalise_username(dm.sender.name)).sample
                   # when :secondary_greeting
                   #   # Do something here....
                   when :answer
                     scores = diagnose(dm.text)
                     formulate_diagnose_reply(scores, formalise_username(dm.sender.name)).sample
                   when :question
                     scores = diagnose(dm.text)
                     formulate_diagnose_reply(scores, formalise_username(dm.sender.name)).sample
                   # when :thanks
                   #   # Do something here....
                   # when :unsure
                   #   # Do something here....
                   # when :positive
                   #   # Do something here....
                   when :negative
                     scores = diagnose(dm.text)
                     formulate_diagnose_reply(scores, formalise_username(dm.sender.name)).sample
                   else
                     bot.reply(dm.text, 140)
                   end
      mistake_reply = Masqueraide::NLP.produce_mistake(real_reply)
      correction = mistake_reply['correction']

      # Message the mistake to the human...
      reply(dm, mistake_reply['text'])
      sleep Random.new.rand 4..10

      # ...then message the correction...
      if mistake_reply['mistakes'] == true
        sleep Masqueraide::NLP.typing_delay(correction) + (Random.new.rand 1..8)
        reply(dm, '*' + correction)
      end
    else
      # ...Or just send a normal direct message.
      log 'Producing a normal direct message.'

      # Do something based on what type of sentiment it is.
      # We also have to do some more NLP to suggest what issue The patient has.
      # Reply once it is ready to answer.
      real_reply = case final_sentiment
                   when :greeting
                     contextualise_greeting(formalise_username(dm.sender.name)).sample
                   # when :secondary_greeting
                   #   # Do something here....
                   when :answer
                     scores = diagnose(dm.text)
                     formulate_diagnose_reply(scores, formalise_username(dm.sender.name)).sample
                   when :question
                     scores = diagnose(dm.text)
                     formulate_diagnose_reply(scores, formalise_username(dm.sender.name)).sample
                   # when :thanks
                   #   # Do something here....
                   # when :unsure
                   #   # Do something here....
                   # when :positive
                   #   # Do something here....
                   when :negative
                     scores = diagnose(dm.text)
                     formulate_diagnose_reply(scores, formalise_username(dm.sender.name)).sample
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

# Start the Socialbot. and catch a CNTRL-C.
begin
  bot = Masqueraide::AI.new('Dr. Brian Mitchell', Brian.new('drbmitchellphd'))
  bot.room.logging = true
  bot.dance true, true
 rescue SystemExit, Interrupt
  puts "\nShutting down chat session..."
  exit
 rescue StandardError => e
   puts e
end