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

begin
  require 'stemmer'
rescue LoadError
  puts "If you want to use stemming for better performance, then please install stemmer from http://rubyforge.org/projects/stemmer or 'gem install stemmer'"
  class String
    def stem
      self
    end
  end
end

module Clusterer
  #the tokenizer algorithms take a block, to which the string tokens are passed
  
  module Tokenizer
    def simple_tokenizer (text, options = {})
      text.gsub(/[^\w\s]/,"").split.each do |word|
        word.downcase!
        word = word.stem unless options[:no_stem]
        yield(word) if word.size > 2 and !STOP_WORDS.include?(word)
      end
    end

    def simple_ngram_tokenizer (text, options = {})
      ngram = options[:ngram] || 3
      
      ngram_list = (0..ngram).collect { []}
      text.split(/[\.\?\!]/).each do |sentence|
        #split the text into sentences, Ngrams cannot straddle sentences
        
        sentence.gsub(/[^\w\s]/,"").split.each do |word|
          word.downcase!
          word = word.stem unless options[:no_stem]
          if word.size > 2 and !STOP_WORDS.include?(word)
            yield(word)
            2.upto(ngram) do |i|
              ngram_list[i].delete_if {|j| j << word; j.size == i ? (yield(j.join(" ")); true) : false}
              ngram_list[i] << [word]
            end
          else
            #the ngrams cannot have a stop word at beginning and end
            2.upto(ngram) {|i| ngram_list[i].delete_if {|j| (j.size == i - 1) ? true : (j << word; false)}}
          end
        end
      end
    end
  end
end
