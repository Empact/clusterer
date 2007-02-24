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
  class DocumentsCentroid < DocumentBase
    attr_reader :no_of_documents

    def initialize(docs = [])
      @no_of_documents = docs.size
      docs.each do |d|
        d.each {|w,f| self[w] = (self[w] || 0.0) + f/@no_of_documents}
      end
    end

    def merge!(centroid)
      @vector_length = nil
      temp = @no_of_documents/(@no_of_documents + centroid.no_of_documents)
      self.each {|w,v| self[w] = v*temp}
      @no_of_documents += centroid.no_of_documents

      temp = centroid.no_of_documents/@no_of_documents
      centroid.each {|w,v| self[w] = (self[w] || 0) + v*temp }
    end
  end
end
