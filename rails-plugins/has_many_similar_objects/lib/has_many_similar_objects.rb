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

require 'active_record'
require 'clusterer'

module Kreeti
  module Acts #:nodoc:
    module HasManySimilarObjects
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def has_many_similar_objects(options={})
          write_inheritable_attribute(:has_many_similar_objects_options, {
                                        :fields => (options[:fields] || self.content_columns.collect {|e|
                                                      e.name if e.type == :string || e.type == :text}.compact)})
          class_inheritable_reader :has_many_similar_objects_options

          has_many :similar_objects, :as => :object, :dependent => :destroy
          include Kreeti::Acts::HasManySimilarObjects::InstanceMethods
        end

        def find_similar_objects(max = 5)
          idf = Clusterer::InverseDocumentFrequency.new()
          docs = find(:all).collect do |o|
            Clusterer::Document.new(o, :idf => idf) {|obj|
              has_many_similar_objects_options[:fields].collect{|f| obj.send(f).to_s}.join(" ")}
          end
          docs.each {|d| d.normalize!(idf)}

          docs.each do |doc1|
            sims = {}
            docs.each do |doc2|
              next if doc1.object == doc2.object
              sims[doc2] = doc1.cosine_similarity(doc2)
            end
            sims = sims.to_a.sort {|a,b| b[1] <=> a[1]}.slice(0,max)
            doc1.object.similar_objects.clear
            sims.each {|d,conf| doc1.object.similar_objects.create(:similar_id => d.object.id, :similarity => conf)}
          end
        end
      end

      module InstanceMethods
      end
    end
  end
end
