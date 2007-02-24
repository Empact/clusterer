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

module Clusterer
  #Document tokenizes the text and stores the count of each token in the document.
  class Document < DocumentBase
    #stores the text using hash

    #Reference to the original text or the object from which the text is derived.
    attr_reader :object
    include(Tokenizer)

    #Reference to the centroid class which is used by Kmeans algorithm
    def self.centroid_class
      DocumentsCentroid
    end

    def initialize (object, options = { })
      @object = object
      send(options[:tokenizer] || :simple_tokenizer,
           ((defined? yield) == "yield" ? yield(object) : object.to_s),
           options[:tokenizer_options]) {|term| self << term }
      
      if (idf = options[:idf])
        idf.increment_documents_count
        self.each_key {|term| idf << term}
      end
    end

    def << (term)
      self[term] = (self[term] || 0) + 1
    end

    def normalize!(idf = nil, add_term = false)
      normalizing_factor = 0.0
      idf.increment_documents_count if add_term
      
      self.each do |term,frequency|
        idf << term if add_term
        f =  idf ? idf[term] : 1.0
        self[term] = Math.log(1 + frequency) * f
        normalizing_factor += self[term] ** 2
      end

      normalizing_factor = Math.sqrt(normalizing_factor)
      normalizing_factor = 1 if normalizing_factor.zero?
      self.each {|term,frequency| self[term] = frequency/normalizing_factor}
      @vector_length = 1
      self.freeze
    end
  end
end
