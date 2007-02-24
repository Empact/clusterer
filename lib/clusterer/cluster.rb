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
  class Cluster 
    attr_reader :centroid, :documents
    include ClusterSimilarity
    
    def initialize(docs = [])
      @documents = docs
    end

    def centroid
      @centroid ||= (@documents.empty? ? nil : @documents[0].class.centroid_class.new(documents))
    end
    
    def merge!(cluster)
      documents.concat(cluster.documents)
      @centroid ? centroid.merge!(cluster.centroid) : @centroid = cluster.centroid
      @intra_cluster_similarity = nil
    end

    def + (cluster)
      c = Cluster.new(self.documents.clone)
      c.merge!(cluster)
      return c
    end

    def ==(cluster)
      cluster && self.documents == cluster.documents 
    end

    def intra_cluster_cosine_similarity
      @intra_cluster_similarity ||= documents.inject(0) {|n,d| n + d.cosine_similarity(centroid) }
    end
  end
end

