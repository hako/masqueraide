#!/usr/bin/ruby
# Dr Brian Mitchell's training routine.

require './corpuses/training/conversation.rb'
require 'classifier-reborn'

nb = ClassifierReborn::Bayes.new(:greeting, :secondary_greeting, :answer, :question, :thanks, :unsure, :positive, :negative)
nb.enable_threshold

# Train patient greetings.
PATIENT_GREETINGS['data'].each do |greeting|
  if /[A-Za-z]\w+\W+(are|s|is|ya|you|)\W\w+/ =~ greeting
    nb.train(:secondary_greeting, greeting)
  else
    nb.train(:greeting, greeting)
  end
end

# Train patient questions.
PATIENT_QUESTION['data'].each do |pq|
  if /([H|h|W|w])\w+\W+(|what|have|often|it|do|you|bad|long|could|can|recommend)\??.+/ =~ pq
    nb.train(:question, pq)
  else
    nb.train(:unsure, pq)
  end
end

# Train thank yous.
THANKS['data'].each do |t|
  nb.train(:thanks, t)
end

# Train unsure responses.
UNSURE['data'].each do |u|
  nb.train(:unsure, u)
end

# Train positive responses.
POSITIVE['data'].each do |p|
  nb.train(:positive, p)
end

# Train negative responses.
NEGATIVE['data'].each do |n|
  nb.train(:negative, n)
end

# Train answering responses.
ANSWER['data'].each do |a|
  nb.train(:answer, a)
end

# STUDY.
def study(nb, text, type)
  result = nb.classify_with_score(text)[0]
  return nb unless result.to_sym == type.to_sym
  if result.to_sym == type.to_sym
    nb.train(type.to_sym, text)
  elsif /[A-Za-z]\w+\W+(are|s|is|ya|you|)\W\w+/ =~ text
    type = :secondary_greeting
    nb.train(type, text)
  elsif /([A-Za-z])\w+\W+(|have|often|it|do|you|bad|long|could|can|recommend)\??.+/ =~ text
    type = :question
    nb.train(type, text)
  end
end

# Retrains the classifier.
def do_your_homework(nb)
  type = GREETINGS['type']
  GREETINGS['data'].each do |x|
    study nb, x, type
  end
  type = THANKS['type']
  THANKS['data'].each do |x|
    study nb, x, type
  end
  type = UNSURE['type']
  UNSURE['data'].each do |x|
    study nb, x, type
  end
  type = PATIENT_QUESTION['type']
  PATIENT_QUESTION['data'].each do |x|
    study nb, x, type
  end
  type = PATIENT_GREETINGS['type']
  PATIENT_GREETINGS['data'].each do |x|
    study nb, x, type
  end
  type = NEGATIVE['type']
  NEGATIVE['data'].each do |x|
    study nb, x, type
  end
  type = POSITIVE['type']
  POSITIVE['data'].each do |x|
    study nb, x, type
  end
  type = ANSWER['type']
  ANSWER['data'].each do |x|
    study nb, x, type
  end
  nb
end

nb = do_your_homework(nb)

# Save the data to corpuses/training/training.msqrd
nb_training_snapshot = Marshal.dump nb
File.open('corpuses/training/training.msqrd', 'w') { |file| file.write(nb_training_snapshot) }
