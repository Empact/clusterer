#The MIT License

#Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>

require 'soap/wsdlDriver'
require 'clusterer'

## try using HTML stripping to get better results

WSDL_URL = "http://api.google.com/GoogleSearch.wsdl"
driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
query = 'kreeti'
key = ""

results = driver.doGoogleSearch(key, query, 0, 10, true, "", 1, "lang_en", "", "")
count= results.resultElements.size
max_count = results.estimatedTotalResultsCount.to_i
results = results.resultElements

while (count < 100 && count <= max_count)
  more_results = driver.doGoogleSearch(key, query, count, 10, true, "", 1, "lang_en", "", "")
  results.concat(more_results.resultElements)
  count += more_results.resultElements.size
end

clusters = Clusterer::Clustering.kmeans_clustering(results.collect {|r| r.title.to_s.gsub(/<\/?[^>]*>/, "") +
                                                     " " + r.snippet.to_s.gsub(/<\/?[^>]*>/, "")})

#writing the output
File.open("temp.html","w") do |f|
  f.write("<ul>")
  clusters.each do |clus|
    f.write("<li>")
    f.write("<ul>")
    clus.each do |d|
      f.write("<li>")
      f.write("<span class='title'>")
      f.write(results[d].title)
      f.write("</span>")
      f.write("<span class='snippet'>")
      f.write(results[d].snippet)
      f.write("</span>")
      f.write("</li>")
    end
    f.write("</ul>")
  end
  f.write("</ul>")
  f.write("</li>")
end
