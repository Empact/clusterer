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

class DocumentCentroidTest < Test::Unit::TestCase
  include Clusterer

  def setup
    @idf = InverseDocumentFrequency.new()
    @d = Document.new("hello world, mea culpa, goodbye world.",@idf).normalize!(@idf)
    @e = Document.new("the world is not a bad place to live.",@idf).normalize!(@idf)
    @f = Document.new("the world is a crazy place to live.",@idf).normalize!(@idf)
    @g = Document.new("unique document.")
    @c1 = Clusterer::Cluster.new([@d, @e, @f])
    @c2 = Clusterer::Cluster.new([@d, @g])
  end

  def test_initialization
    c = DocumentsCentroid.new([@d, @e, @f])
    assert 3, c.no_of_documents
    assert c.vector_length
  end

  def test_merge!
    c1 = DocumentsCentroid.new([@d, @e, @f])
    c2 = DocumentsCentroid.new([@d, @g])
    c3 = c2.clone
    t = c1.vector_length
    c1.merge!(c2)
    assert 5, c1.no_of_documents
    assert_equal c2, c3
    assert_not_equal t, c1.vector_length

    c4 = DocumentsCentroid.new()
    t = c1.vector_length
    c1.merge!(c4)
    assert 5, c1.no_of_documents
    assert_equal t, c1.vector_length
  end
end
