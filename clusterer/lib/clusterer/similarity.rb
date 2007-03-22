#The MIT License

###Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>

module Clusterer
  module DocumentSimilarity
    #find similarity between two documents, or cluster centroids
    def cosine_similarity(document)
      return 1.0 if self.empty? || document.nil? || document.empty?
      similarity = 0
      self.each do |w,value|
        similarity += (value * (document[w] || 0))
      end
      similarity /= (self.vector_length * document.vector_length)
    end
  end

  module ClusterSimilarity
   #the algorithms given below find similarity between two clusters
    def intra_cluster_similarity(y)
      (self+y).intra_cluster_cosine_similarity - self.intra_cluster_cosine_similarity - y.intra_cluster_cosine_similarity
    end

    def centroid_similarity(y)
      self.centroid.cosine_similarity(y.centroid)
    end

    def upgma(y)
      self.documents.inject(0) do |n,d|
        n + y.documents.inject(0) {|s,e| s + d.cosine_similarity(e) }
      end / (self.documents.size * y.documents.size)
    end
  end
end
