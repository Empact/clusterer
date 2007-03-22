# Copyright (c) 2006 Surendra K. Singhi <ssinghi@kreeti.com>


require File.join(File.dirname(__FILE__), 'abstract_unit')
class ClusterableTest < Test::Unit::TestCase
  fixtures :comments
  def test_kmeans_clustering
    c = Comment.cluster()
    assert_not_equal [], c
    assert c[0].centroid
    assert_not_equal [], c[0].documents
    assert_equal 2, Comment.cluster(:no_of_clusters => 2).size
  end

  def test_hierarchical_clustering
    assert_not_equal [], Comment.cluster(:algorithm => :hierarchical)
    assert_equal 2, Comment.cluster(:algorithm => :hierarchical, :no_of_clusters => 2).size
  end
end
