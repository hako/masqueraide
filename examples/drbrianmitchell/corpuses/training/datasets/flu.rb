# Dr Brian Mitchell flu dataset.

FLU = {
  'type' => :flu,
  'score' => 0,
  'symptoms' => [
    'sore throat',
    'runny nose',
    'blocked nose',
    'fever',
    'sneezing',
    'exhausted',
    'dizzy',
    'hot headed',
    'hot',
    'nausea',
    'stinging',
    'dizzyness',
    'diarrhoea',
    'joint pain',
    'tiredness',
    'tired',
    'headache',
    'chesty cough'
  ],
  'keywords' => %w(
    sore
    throat
    blocked
    tired
    fever
    stinging
    nausea
    hot
    dizzyness
    dizzy
    pain
    nose
    runny
    sneezing
    chesty
    cough
    headache),
  'related' => [
    :common_cold
  ],
  'worse_conditions' => [
    'bronchitis',
    'chronic bronchitis',
    'influenza',
    'pneumonia',
    'a chest or ear infection',
    'a chest infection'
  ],
  'possible_conditions' => [
    'a dry cough',
    'the common cold',
    'asthma'
  ],
  'treatment' => [
    'Ibuprofen',
    'Paracetamol',
    'some rest'
  ]
}
