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
  #DocumentsCount is used to store the count of number of documents seen.
  #This class could have been just replaced by a simple variable, in
  #InverseDocumentFrequency class but to make the InverseDocumentFrequency
  #class more flexible and be able to store the count in DB/File store
  #this class is provided.
  class DocumentsCount
    attr_reader :value
    def initialize 
      @value = 0
    end

    def increment
      @value +=1
    end
  end

  #TermsCount is used to store the count of number of documents in which the
  #term has been seen. This class could have been just replaced by a simple
  #hash object, in InverseDocumentFrequency class but to make the
  #InverseDocumentFrequency class more flexible and be able to store the
  #term count in DB/File store this class is provided.
  class TermsCount < Hash
    def increment_count(term)
      self[term] = (self[term] || 0) + 1
    end
  end
  
  #InverseDocumentFrequency maintains a count of the total number of documents
  #and the number of documents where a term has been seen with the help of helper
  #classes. It also calculates the normalizing factor, the formula for whichis
  #Math.log(total_number of documents/ number of documents containing the term)
  class InverseDocumentFrequency < Hash
    def documents_count
      @documents_count.value
    end

    def clean_cached_normalizing_factor
      @nf.clear
    end
    
    def initialize (options = { })
      @terms_count = options[:terms_count] || TermsCount.new
      @nf = Hash.new
      @documents_count = options[:documents_count] || DocumentsCount.new
    end

    def increment_documents_count
      @documents_count.increment
    end
    
    def << (term)
      @terms_count.increment_count(term) unless term.nil? || term.empty?
    end

    def [] (term)
      @nf[term] ||= (@terms_count[term] && @documents_count.value >1) ? Math.log(@documents_count.value/@terms_count[term].to_f) : 1.0
    end
  end
end

