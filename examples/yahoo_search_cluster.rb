#The MIT License

#Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'clusterer'
require 'ysearch-rb/lib/ysearch'

## try using HTML stripping to get better results

# get the query parameter
query = "kreeti"

##
# create a web search object:
# Arguments:
# 1. App ID (You can get one at http://developer.yahoo.net)
# 2. The query
# 3. type can be one of: 'all', 'any' or 'phrase'
# 4. The no. of results
##
obj = WebSearch.new('', query, 'all', 100)

results = obj.parse_results

#kmeans_clustering
clusters = Clusterer::Clustering.cluster(:hierarchical, results) {|r| r['Title'].to_s.gsub(/<\/?[^>]*>/, "") +
  " " + r['Summary'].to_s.gsub(/<\/?[^>]*>/, "")}

#writing the output
File.open("temp.html","w") do |f|
  f.write("<ul>")
  clusters.each do |clus|
    f.write("<li>")
    f.write("<ul>")
    clus.each do |result|
      f.write("<li>")
      f.write("<span class='title'>")
      f.write(results['Title'])
      f.write("</span>")
      f.write("<span class='snippet'>")
      f.write(results['Summary'])
      f.write("</span>")
      f.write("</li>")
    end
    f.write("</ul>")
  end
  f.write("</ul>")
  f.write("</li>")
end
