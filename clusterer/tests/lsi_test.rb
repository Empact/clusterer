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

class LsiTest < Test::Unit::TestCase
  include Clusterer

  def setup
    @idf = InverseDocumentFrequency.new()
    @d = DocumentArray.new("hello world, mea culpa, goodbye world.",:idf => @idf)
    @e = DocumentArray.new("the world is not a bad place to live.",:idf => @idf)
    @f = DocumentArray.new("the world is a crazy place to live.",:idf => @idf)
    @g = DocumentArray.new("unique document.")
    [@d, @e, @f, @g].each {|d| d.normalize! }
  end
  
  def test_initialize
    l = Lsi.new([@d, @e, @f, @g])
  end

  def test_perform_svd
    l = Lsi.new([@d, @e, @f, @g])
    l.perform_svd(1.0)
    assert l.instance_variable_get("@t")
    assert l.instance_variable_get("@d")
    assert l.instance_variable_get("@s")
    assert l.instance_variable_get("@t") * l.instance_variable_get("@s") * l.instance_variable_get("@d")
    l = Lsi.new([@d, @e, @f])
    l.perform_svd(0.1)
    assert l.instance_variable_get("@t")
    assert l.instance_variable_get("@d")
    assert l.instance_variable_get("@s")
    assert l.instance_variable_get("@t") * l.instance_variable_get("@s") * l.instance_variable_get("@d")
  end
  
  def test_add_document
    l = Lsi.new([@d, @e, @f, @g])
    l << @d
    l.perform_svd(0.75)
  end

  def test_cluster_documents
    l = Lsi.new([@d, @e, @f, @g])
    puts l.cluster_documents(2).collect {|c| c.collect {|d| d.object } }.inspect
    assert_equal 2, l.cluster_documents(2).size
    assert_equal 2, l.cluster_documents(2,:algorithm => :hierarchical).size
    assert_equal 2, l.cluster_documents(2, :algorithm => :bisecting_kmeans).size
  end

  def test_search
    l = Lsi.new([@d, @e, @f, @g])
    assert l.search(@f).size >= 1
  end
end
