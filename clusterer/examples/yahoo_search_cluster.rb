#The MIT License

#Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'clusterer'
require 'rubygems'
require 'yahoo/web_search'


ys = Yahoo::WebSearch.new ""
query = "kolkata"
results, = ys.search query, 10

## try using HTML stripping to get better results

#kmeans
clusters = Clusterer::Clustering.cluster(:hierarchical, results, :no_stem => true, :tokenizer => :simple_ngram_tokenizer){|r|
  r.title.to_s.gsub(/<\/?[^>]*>/, "") + " " + r.summary.to_s.gsub(/<\/?[^>]*>/, "")}

#writing the output
File.open("temp.html","w") do |f|
  f.write("<ul>")
  clusters.each do |clus|
    f.write("<li>")
    f.write("<h4>")
    clus.centroid.to_a.sort{|a,b| b[1] <=> a[1]}.slice(0,5).each {|w| f.write("#{w[0]} - #{format '%.2f',w[1]}, ")}
    f.write("</h4>")
    f.write("<ul>")
    clus.documents.each do |doc|
      result = doc.object
      f.write("<li>")
      f.write("<span class='title'>")
      f.write(result.title)
      f.write("</span>")
      f.write("<span class='snippet'>")
      f.write(result.summary)
      f.write("</span>")
      f.write("</li>")
    end
    f.write("</ul>")
  end
  f.write("</ul>")
  f.write("</li>")
end
