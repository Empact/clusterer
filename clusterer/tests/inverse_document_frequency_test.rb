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

class InverseDocumentFrequencyTest < Test::Unit::TestCase
  include Clusterer

  def test_insertion
    idf = InverseDocumentFrequency.new()
    idf << "hello"
    assert_equal 1, idf.instance_variable_get("@terms_count").size
    assert_in_delta 1.0, idf.instance_variable_get("@terms_count")["hello"], 0.01
    idf << "hello"
    assert_equal 2.0, idf.instance_variable_get("@terms_count")["hello"]
    assert_equal 1, idf.instance_variable_get("@terms_count").size
    
    idf << "world"
    assert_equal 2, idf.instance_variable_get("@terms_count").size
  end

  def test_documents_count
    idf = InverseDocumentFrequency.new()
    Document.new("the world is not a bad place to live.", :idf => idf)
    Document.new("the world is a crazy place to live.", :idf => idf)
    assert_equal 2, idf.documents_count
  end

  def test_clean_cached_normalizing_factor
    idf = InverseDocumentFrequency.new()
    Document.new("the world is not a bad place to live.", :idf => idf)
    Document.new("hello, the world is a crazy place to live.", :idf => idf)
    t ="crazy".stem
    f = idf[t]
    assert_in_delta Math.log(2/1), f, 0.1
    Document.new("the world is a weird place to live.", :idf => idf)
    assert_equal f, idf[t]
    idf.clean_cached_normalizing_factor
    assert_not_equal f, idf[t]
  end

  def test_array_index
    idf = InverseDocumentFrequency.new()
    Document.new("the world is not a bad place to live.", :idf => idf)
    assert_in_delta 1.0, idf["world"], 0.001
    assert_in_delta 1.0, idf["hello"], 0.001
    
    Document.new("hello, the world is a crazy place to live.", :idf => idf)
    idf.clean_cached_normalizing_factor
    idf << "hello"
    assert idf["hello"] < 0.99
  end
end
