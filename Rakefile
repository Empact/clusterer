#The MIT License

###Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>

require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = "clusterer"
  s.version = "0.1.0"
  s.author = "Surendra K Singhi"
  s.email = "ssinghi@kreeti.com"
  s.homepage = "http://rubyforge.org/projects/clusterer/"
  s.platform = Gem::Platform::RUBY
  s.summary = "A library of clustering algorithms for text data."
  s.files = FileList["{bin,tests,lib,docs,examples}/**/*"].exclude("rdoc").to_a
  s.require_path = "lib"
  s.autorequire = "clusterer"
  s.test_file = "tests/clusterer_test.rb"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.add_dependency("stemmer", ">= 0.0.0")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
