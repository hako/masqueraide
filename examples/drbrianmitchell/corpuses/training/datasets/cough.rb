# Dr Brian Mitchell cough dataset.

COUGH = {
  'type' => :cough,
  'score' => 0,
  'symptoms' => [
    'sore throat',
    'wheezing',
    'chest pain',
    'allergy',
    'aching',
    'heavy',
    'heavy cough',
    'bloating',
    'gasping',
    'coughing',
    'asthma',
    'breathless',
    'whooping cough',
    'breathlessness',
    'chest infection'
  ],
  'keywords' => %w(
    sore
    throat
    coughing
    chesty
    bloated
    bloat
    gasping
    heavy
    cough
    infection
    breathless
    allergy
    asthma
    wheezing),
  'related' => [
    :smoking,
    :hay_fever,
    :bronchitis,
    :dry_cough
  ],
  'worse_conditions' => [
    'lung cancer',
    'chronic bronchitis',
    'pneumonia',
    'chest or ear infection',
    'chest infection'
  ],
  'possible_conditions' => [
    'a dry cough',
    'a whooping cough',
    'heartburn',
    'a smokers cough',
    'a persistent cough',
    'asthma',
    :flu
  ],
  'treatment' => [
    'cough medicine',
    'Expectorants (Cough Medicine)',
    'antibiotics'
  ]
}
