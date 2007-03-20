#The MIT License

###Copyright (c) 2006 Surendra K Singhi <ssinghi AT kreeti DOT com>

require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'

Rake::TestTask.new do |t|
  t.libs << "tests"
  t.test_files = FileList['tests/*_test.rb']
  t.verbose = true
end

spec = Gem::Specification.new do |s|
  s.name = "clusterer"
  s.version = "0.1.9"
  s.author = "Surendra K Singhi"
  s.email = "ssinghi@kreeti.com"
  s.homepage = "http://rubyforge.org/projects/clusterer/"
  s.platform = Gem::Platform::RUBY
  s.summary = "A library of clustering and classification algorithms for text data."
  s.files = FileList["{bin,tests,lib,docs,examples}/**/*"].exclude("rdoc").to_a
  s.require_path = "lib"
  s.autorequire = "clusterer"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.add_dependency("stemmer", ">= 0.0.0")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end
