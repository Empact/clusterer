#The MIT License

###Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'clusterer'

class TestAlgorithms < Test::Unit::TestCase
  include Clusterer

  def setup
    @idf = InverseDocumentFrequency.new()
    @d = Document.new("hello world, mea culpa, goodbye world.", :idf => @idf).normalize!(@idf)
    @e = Document.new("the world is not a bad place to live.", :idf => @idf).normalize!(@idf)
    @f = Document.new("the world is a crazy place to live.", :idf => @idf).normalize!(@idf)
    @g = Document.new("unique document.")
  end

  def test_kmeans
#    3.times do
#       assert_equal 2, Algorithms.kmeans([@d, @e, @f, @g], 2).size
#       assert_equal 2, Algorithms.kmeans([@d, @e, @f, @g], 2, :maximum_iterations => 5).size
      assert_equal 2, Algorithms.kmeans([@d, @e, @f, @g], 2, :maximum_iterations => 5,
                                        :seeds => [Cluster.new([@d]), Cluster.new([@d])]).size
#      assert_equal 3, Algorithms.kmeans([@d, @e, @f, @g],3).size
#    end
  end

  def test_hierarchical_clustering
    assert_equal 2, Algorithms.hierarchical([@d, @e, @f, @g], 2, :similarity_function => :intra_cluster_similarity).size
    assert_equal 1, Algorithms.hierarchical([@d, @e, @f, @g], 1, :similarity_function => :centroid_similarity).size
    assert_equal 2, Algorithms.hierarchical([@d, @e, @f, @g], 2, :similarity_function => :upgma).size
    assert_equal 2, Algorithms.hierarchical([@d, @e, @f, @g], 2, :refined => true).size
    assert_equal 3, Algorithms.hierarchical([@d, @e, @f, @g], 3, :similarity_function => :centroid_similarity,
                                            :refined => true).size
  end

  def test_bisecting_kmeans
    assert_equal 2, Algorithms.bisecting_kmeans([@d, @e, @f, @g], 2, :maximum_iterations => 5).size
    assert_equal 1, Algorithms.bisecting_kmeans([@d, @e, @f, @g], 1).size
    assert_equal 2, Algorithms.bisecting_kmeans([@d, @e, @f, @g], 2).size
    assert_equal 2, Algorithms.bisecting_kmeans([@d, @e, @f, @g], 2, :maximum_iterations => 5, :refined => true).size
    assert_equal 3, Algorithms.bisecting_kmeans([@d, @e, @f, @g], 3, :refined => true).size
  end

end
