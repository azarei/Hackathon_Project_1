require "#{File.dirname(__FILE__)}/corpus"
require "#{File.dirname(__FILE__)}/classifier"

class Analyser
  def initialize
    @positive = Corpus.new 'positive'
    @negative = Corpus.new 'negative'
  end

  def train_positive
    puts 'Training analyser with +ve sentiment'
    @positive.load_from_directory 'data/positive'
    puts '+ve sentiment training complete'
  end

  def train_negative
    puts 'Training analyser with -ve sentiment'
    @negative.load_from_directory 'data/negative'
    puts '-ve sentiment training complete'
  end

  def write_to_db sentence, sentiment
    p sentiment
    if sentiment == Sentiment::NEGATIVE
      @negative.add Document.new(sentence)
    else
      @positive.add Document.new(sentence)
    end
  end

  def analyse sentence
    Classifier.new(@positive, @negative).classify(sentence)
  end

end
