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

class DocumentArrayTest < Test::Unit::TestCase
  include Clusterer

  def setup
    @idf = InverseDocumentFrequency.new()
    @d = DocumentArray.new("hello world, mea culpa, goodbye world.",:idf => @idf)
    @e = DocumentArray.new("the world is not a bad place to live.",:idf => @idf).normalize!(@idf)
    @f = DocumentArray.new("the world is a crazy place to live.",:idf => @idf).normalize!(@idf)
    @g = DocumentArray.new("unique document.")
  end
  
  def test_insert
    t = @d.term_array_position_mapper('weird')
    assert_nil @d[t]
    @d << "weird"
    assert @d[t]
    assert_equal @d[t] + 1, (@d << "weird"; @d[t])
  end

  def test_term_array_position_mapper
    @d.term_array_position_mapper("world")
  end
  
  def test_vector_length
    assert_not_nil @f.vector_length
    assert_in_delta 1.0, @f.vector_length, 0.01
  end

  def test_object
    assert_equal "unique document.", @g.object
  end

  def test_normalize!
    @d.normalize!
    assert_in_delta 1.0, @d.vector_length, 0.01
  end
end
