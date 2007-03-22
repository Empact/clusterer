#--
###Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'clusterer'

class TestSimilarity < Test::Unit::TestCase
  include Clusterer

  def setup
    @d = Document.new("hello world, mea culpa, goodbye world.")
    @e = Document.new("the world is not a bad place to live.").normalize!
    @f = Document.new("the world is a crazy place to live.").normalize!
    @g = Document.new("unique document.")

    @c1 = Clusterer::Cluster.new([@d, @e, @f])
    @c2 = Clusterer::Cluster.new([@g, @g])
  end

  def test_cosine_similarity
    assert_in_delta 1.0, @d.cosine_similarity(@d), 0.01
    assert_in_delta 1.0, @e.cosine_similarity(@e), 0.01
    assert_in_delta 0.0, @f.cosine_similarity(@g), 0.01
    assert @e.cosine_similarity(@f) > 0.5  # very similar
  end

  def test_intra_cluster_similarity
    assert @c1.intra_cluster_similarity(@c2) < 0
    assert_in_delta 0.0, @c1.intra_cluster_similarity(@c1), 0.01
  end

  def test_centroid_similarity
    assert_in_delta 0.0, @c1.centroid_similarity(@c2), 0.01
    assert_in_delta 1.0, @c1.centroid_similarity(@c1), 0.01
  end

  def test_upgma
    assert_in_delta 0, @c1.upgma(@c2), 0.01
    assert @c1.upgma(@c1) > 0.5
  end
end
