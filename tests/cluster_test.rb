#The MIT License

###Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'clusterer'

class TestCluster < Test::Unit::TestCase
  include Clusterer

  def setup
    @idf = InverseDocumentFrequency.new()
    @d = Document.new("hello world, mea culpa, goodbye world.",@idf).normalize!(@idf)
    @e = Document.new("the world is not a bad place to live.",@idf).normalize!(@idf)
    @f = Document.new("the world is a crazy place to live.",@idf).normalize!(@idf)
    @g = Document.new("unique document.")
    @c1 = Cluster.new([@d, @e, @f])
    @c2 = Cluster.new([@d, @g])
  end

  def test_centroid
    assert @c1.centroid
    assert_nil Cluster.new.centroid
  end

  def test_merge!
    @c1.merge!(@c2)
    assert_nil @c1.instance_variable_get("@intra_cluster_similarity")
    c = Cluster.new
    c.merge!(@c2)
    assert_equal c.centroid, @c2.centroid
  end

  def test_add
    c= @c1 + @c2
    assert_not_equal c, @c1
    assert_not_equal c, @c2
    assert_equal (Cluster.new + @c1), @c1
  end

  def test_equal
    assert_not_equal @c1, @c2
    assert_not_equal @c1, nil
    assert_equal @c1, Cluster.new([@d, @e, @f])
  end

  def test_intra_cluster_cosine_similarity
    assert_equal Cluster.new.intra_cluster_cosine_similarity,Cluster.new.intra_cluster_cosine_similarity
    assert @c1.intra_cluster_cosine_similarity > 0
    assert_not_equal @c1.intra_cluster_cosine_similarity, @c2.intra_cluster_cosine_similarity
  end
end
