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
  require 'linalg'
  $LINALG = true
rescue LoadError
  warn 'For faster LSI support, please install Linalg: '
  require 'clusterer/lsi/dmatrix'
end

require 'clusterer/lsi/document_vector'
require 'clusterer/lsi/documents_centroid_vector'

module Clusterer
  class Lsi
    include Linalg if $LINALG

    attr_reader :documents
    def initialize(docs)
      @documents = docs
    end

    def rebuild_if_needed
      perform_svd unless @t && @d && @s
    end

    def clear_cached_results
      @t= @s= @d= @s_inv= @sd= nil
    end
    
    def perform_svd (cutoff = 0.80)
      matrix = DMatrix[*@documents].transpose
      @t, @s, @d =  matrix.svd
      val = @s.trace * cutoff
      cnt = -1
      (0..([@s.row_size, @s.column_size].min - 1)).inject(0) {|n,v| cnt += 1; (n > val) ? break : n + @s[v,v] }
      @t = DMatrix.join_columns((0..cnt).collect {|i|@t.column(i) })
      @d = DMatrix.join_rows((0..cnt).collect {|i| @d.row(i) })
      @s = DMatrix.join_columns((0..cnt).collect {|i|@s.column(i) })
      @s = DMatrix.join_rows((0..cnt).collect {|i|@s.row(i) }) unless @s.column_size == cnt
    end

    def cluster_documents(k, options = { })
      rebuild_if_needed
      cnt = -1
      clusters = Algorithms.send(options[:algorithm] || :kmeans, 
                                 sd.column_vectors.collect{|c| c.position = (cnt += 1); c}, k, options)
      clusters.collect {|clus| clus.documents.collect {|d| @documents[d.position]}}
    end
    
    def search(document, threshold = 0.5)
      rebuild_if_needed
      vec = $LINALG ? DMatrix[document] : DMatrix[document] #DMatrix[document] #transform_to_vector(document)
      vec = (vec * @t) * s_inv
      results = []
      vec = (vec * @s).transpose # * @s
      vec = vec.column(0) unless $LINALG
      sd.column_vectors.each_with_index {|d,i| results << documents[i] if d.cosine_similarity(vec) >= threshold}
      results
    end

    def <<(doc)
      @documents << doc
    end
    
    private
    def sd
      @sd ||= @s*@d
    end
    
    def s_inv
      @s_inv ||=  @s.inverse
    end
  end
end
