#The MIT License

#Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>

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
obj = WebSearch.new('YahooDemo', query, 'all', 100)

results = obj.parse_results

# count= results.resultElements.size
# max_count = results.estimatedTotalResultsCount.to_i
# results = results.resultElements

# while (count < 100 && count <= max_count)
#   more_results = driver.doGoogleSearch(key, query, count, 10, true, "", 1, "lang_en", "", "")
#   results.concat(more_results.resultElements)
#   count += more_results.resultElements.size
# end

#kmeans_clustering
clusters = Clusterer::Clustering.hierarchical_clustering(results.collect {|r| r['Title'].to_s.gsub(/<\/?[^>]*>/, "") +
                                                     " " + r['Summary'].to_s.gsub(/<\/?[^>]*>/, "")})

#writing the output
File.open("temp.html","w") do |f|
  f.write("<ul>")
  clusters.each do |clus|
    f.write("<li>")
    f.write("<ul>")
    clus.each do |d|
      f.write("<li>")
      f.write("<span class='title'>")
      f.write(results[d]['Title'])
      f.write("</span>")
      f.write("<span class='snippet'>")
      f.write(results[d]['Summary'])
      f.write("</span>")
      f.write("</li>")
    end
    f.write("</ul>")
  end
  f.write("</ul>")
  f.write("</li>")
end
