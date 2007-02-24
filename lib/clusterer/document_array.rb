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
  class DocumentArray < Array
    #stores the text in an array format, used with LSI or SVD
    attr_reader :object
    
    @@term_array_position_mapper = {}
    include(Tokenizer)

    def initialize(object = "",options = { })
      @object = object
      super(@@term_array_position_mapper.size,0.0)
      send(options[:tokenizer] || :simple_tokenizer,
           ((defined? yield) == "yield" ? yield(object) : object.to_s),
           options[:tokenizer_options]) {|term| self << term }

      if (idf = options[:idf])
        idf.increment_documents_count
        self.each_with_index {|ind,val| idf << @@term_array_position_mapper.index(ind) if val && val > 0.0}
      end
    end
    
    def << (term)
      self[term_array_position_mapper(term)] = (self[term_array_position_mapper(term)] || 0) + 1
    end
    
    def normalize!(idf = nil, add_term = false)
      normalizing_factor = 0.0
      idf.increment_documents_count if add_term

      self[@@term_array_position_mapper.size - 1] ||= 0.0 

      self.each_with_index do |frequency, ind|
        f = add_term ? (idf << term) : (idf ? idf[@@term_array_position_mapper.index(ind)] : 1.0)
        self[ind] = (frequency || 0) * f
        normalizing_factor += self[ind] ** 2
      end
      
      normalizing_factor = Math.sqrt(normalizing_factor)
      normalizing_factor = 1 if normalizing_factor.zero?
      self.each_with_index {|frequency, ind| self[ind] = frequency/normalizing_factor}
      @vector_length = 1.0
      self.freeze
    end
    
    def vector_length
      @vector_length ||= Math.sqrt(self.inject(0) {|n,y| n + y*y})
    end

    def term_array_position_mapper(term)
      if (x = @@term_array_position_mapper[term])
        x
      else
        @@term_array_position_mapper[term] = @@term_array_position_mapper.size
      end
    end
  end
end
