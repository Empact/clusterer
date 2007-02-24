#The MIT License

###Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'clusterer'

class TestBayes < Test::Unit::TestCase
  include Clusterer

  def setup
    @idf = InverseDocumentFrequency.new()
    @d = Document.new("hello world, mea culpa, goodbye world.",:idf => @idf).normalize!(@idf)
    @e = Document.new("the world is not a bad place to live.",:idf => @idf).normalize!(@idf)
    @f = Document.new("the world is a crazy place to live.",:idf => @idf).normalize!(@idf)
    @g = Document.new("unique document.")
  end

  def test_multinomial
    b = MultinomialBayes.new(["good", "evil"])
    b.train(@d, "good")
    b.train(@e, :good)
    b.train_evil @g
    assert_raise(ArgumentError) { b.train(@e, :funny) }
    assert_equal :good, b.classify(@f)
    assert !b.distribution(@f).empty?
  end

  def test_complement
    b = ComplementBayes.new(["good", "evil"])
    b.train(@d, "good")
    b.train(@e, :good)
    b.train_evil @g
    assert_raise(ArgumentError) { b.train(@e, :funny) }
    assert_equal :good, b.classify(@f)
    assert !b.distribution(@f).empty?
  end

  def test_weight_normalized_complement
    b = WeightNormalizedComplementBayes.new(["good", "evil"])
    b.train(@d, "good")
    b.train(@e, :good)
    b.train(@g, "evil")
    assert_raise(ArgumentError) { b.train(@e, :funny) }
    assert_equal :good, b.classify(@f)
    assert !b.distribution(@f).empty?
    b.train(@f, "good")
    assert b.instance_variable_get("@weighted_likelihood").empty?
    assert_equal :good, b.classify(@f)
    assert !b.instance_variable_get("@weighted_likelihood").empty?
  end

  def test_weight_normalized_multinomial
    b = WeightNormalizedMultinomialBayes.new(["good", "evil"])
    b.train(@d, "good")
    b.train(@e, :good)
    b.train(@g, "evil")
    assert_raise(ArgumentError) { b.train(@e, :funny) }
    assert_equal :good, b.classify(@f)
    assert !b.distribution(@f).empty?
    b.train(@f, "good")
    assert b.instance_variable_get("@weighted_likelihood").empty?
    assert_equal :good, b.classify(@f)
    assert !b.instance_variable_get("@weighted_likelihood").empty?
  end
end
