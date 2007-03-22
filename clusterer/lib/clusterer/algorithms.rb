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
  class Algorithms
    class << self
      
private
      def random_cluster_seeds(documents,k)
        temp = []
        (1..k).collect do
          t= nil
          while(!t || temp.include?(t))
            t= Cluster.new([documents[rand(documents.size)]]);
          end
          temp << t
          t
        end
      end
      
public
      def kmeans(documents, k, options = { })
        old_clusters = Array.new(k)
        max_iter = options[:maximum_iterations] || 10
        clusters = options[:seeds] || random_cluster_seeds(documents, k)
        sim_fun = options[:similarity_function] || :cosine_similarity
        
        iter = 0
        while (!max_iter || iter < max_iter) && clusters != old_clusters
          puts "Iteration ....#{iter}"
          k.times {|i| old_clusters[i] = clusters[i]; clusters[i] = []}

          documents.each do |document|
            max_index = (0..k-1).max do |i,j|
              document.send(sim_fun, old_clusters[i].centroid) <=> document.send(sim_fun, old_clusters[j].centroid)
            end
            clusters[max_index] << document
          end

          k.times {|i| clusters[i] = Cluster.new(clusters[i])}
          iter += 1
        end
        return clusters
      end

      def bisecting_kmeans(documents, k, options = { })
        clusters = [Cluster.new(documents)]
        while  clusters.size < k
          lg_clus = clusters.max {|a, b| a.documents.size <=> b.documents.size} #largest cluster
          clusters.delete(lg_clus)
          clusters.concat(kmeans(lg_clus.documents,2))
        end
        options[:refined] ? clusters = kmeans(documents, k, options.merge(:seeds => clusters)) : clusters
      end

      def hierarchical(documents, k, options = { })
        clusters = documents.collect {|d| Cluster.new([d])}
        iter = 0
        sim_fun = options[:similarity_function] || :upgma
        options[:similarity_function] = nil
        while clusters.size > k
          puts "Iteration ....#{iter}"

          pairs = []
          clusters.each_with_index {|c,i| pairs.concat(clusters.slice(i+1,clusters.size).collect{|f| [c,f] })}
          pair = pairs.max {|a,b| a[0].send(sim_fun, a[1]) <=> b[0].send(sim_fun, b[1]) }
          clusters.delete(pair[1])
          pair[0].merge!(pair[1])

          iter += 1
        end
        options[:refined] ? clusters = kmeans(documents, k, options.merge(:seeds => clusters)) : clusters
      end
    end
  end
end
