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
  include Clusterer::Tokenizer 
  def test_simple_tokenizer
    x = []
    simple_tokenizer("good! morrow!! the AB called") {|w| x << w}
    assert_equal 3, x.size
    assert_equal "morrow".stem, x[1]
    assert_equal "call", x[2]
  end

  def test_simple_tokenizer_with_no_stemming
    x = []
    simple_tokenizer("good! morrow!! the AB called", :no_stem => true) {|w| x << w}
    assert_equal 3, x.size
    assert_equal "morrow", x[1]
    assert_equal "called", x[2]
  end

  def test_simple_ngram_tokenizer_1
    x = []
    simple_ngram_tokenizer("Good! morrow!! the AB",1) {|w| x << w}
    assert_equal 2, x.size
    assert_equal "morrow".stem, x[1]
  end

  def test_simple_ngram_tokenizer
    x = []
    simple_ngram_tokenizer("The cow is a cool holy animal.",:ngram => 1) {|w| x << w}
    assert_equal 4, x.size
    x = []
    simple_ngram_tokenizer("The cow is a cool holy animal.",:ngram => 2) {|w| x << w}
    assert_equal 6, x.size
    assert x.include?(["holy".stem, "animal".stem].join(" "))
    x = []
    simple_ngram_tokenizer("The cow is a cool holy animal.",:ngram => 3) {|w| x << w}
    assert_equal 7, x.size
    assert x.include?(["holy".stem, "animal".stem].join(" "))
    assert x.include?(["cool".stem, "holy".stem, "animal".stem].join(" "))
    x = []
    simple_ngram_tokenizer("Ruby on Rails is cool.") {|w| x << w}
    assert_equal 5, x.size
    assert x.include?(["ruby".stem, "on".stem, "rails".stem].join(" "))
    assert x.include?(["rails".stem, "is".stem, "cool".stem].join(" "))
  end
end
