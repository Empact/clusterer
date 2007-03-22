# Copyright (c) 2006 Surendra K. Singhi <ssinghi@kreeti.com>


# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions: 

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software. 

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  

require 'active_record'
require 'clusterer'

module ActiveRecord # :nodoc:
  module Acts #:nodoc:
    module Classifiable
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_classifiable(options = {})
          write_inheritable_attribute(:acts_as_classifiable_options, {
                                        :fields => (options[:fields] || self.content_columns.collect {|e|
                                                      e.name if e.type == :string || e.type == :text}.compact),
                                        :categories => options[:categories]
                                      })

          class_inheritable_reader :acts_as_classifiable_options

          include ActiveRecord::Acts::Classifiable::InstanceMethods
          extend ActiveRecord::Acts::Classifiable::SingletonMethods
        end

        def classifier_record(identifier = nil)
          record = find_classifier_record(identifier)
          if record
            record.load_classifier
          else
            record = ClassifierModel.new
            record.classifiable_type = self.to_s
            record.identifier = identifier
            record.classifier = Clusterer::MultinomialBayes.new(acts_as_classifiable_options[:categories])
          end
          return record
        end
      end

      module SingletonMethods
        def find_classifier_record(identifier = nil)
          ClassifierModel.find_by_classifiable_type_and_identifier(self.to_s,identifier)
        end

        def method_missing(name, *args)
          if name.to_s =~ /^(un)?train$/
            instances = args[0]
            categories = args[1]
            identifier = args[2]
            record = classifier_record(identifier)
            instances.each_with_index do |inst, i|
              record.classifier.send(name.to_s, inst.get_clusterer_document, categories[i])
            end
            record.save
          elsif name.to_s =~ /^(un)?train_/
            category = name.to_s.gsub(/(un)?train_([\w]+)/, '\2')
            instances = args[0]
            identifier = args[1]
            record = classifier_record(identifier)
            instances.each do |inst|
              record.classifier.send(name.to_s, inst.get_clusterer_document, category)
            end
            record.save
          elsif name.to_s == "distribution" || name.to_s == "classify"
            instances = args[0]
            identifier = args[1]
            record = classifier_record(identifier)
            results = []
            instances.each do |inst|
              results << record.classifier.send(name.to_s, inst.get_clusterer_document)
            end
            return results
          else
            super
          end
        end
      end

      module InstanceMethods
        def method_missing(name, *args)
          if name.to_s =~ /^(un)?train$/
            category = args[0]
            identifier = args[1]
            record = self.class.classifier_record(identifier)
            record.classifier.send(name.to_s, self.get_clusterer_document, category)
            record.save
          elsif name.to_s =~ /^(un)?train_/
            identifier = args[0]
            category = name.to_s.gsub(/(un)?train_([\w]+)/, '\2').to_sym
            record = self.class.classifier_record(identifier)
            record.classifier.send(name.to_s, self.get_clusterer_document, category)
            record.save
          elsif name.to_s == "distribution" || name.to_s == "classify"
            identifier = args[0]
            record = self.class.classifier_record(identifier)
            return record.classifier.send(name.to_s, get_clusterer_document)
          else
            super
          end
        end

        def get_clusterer_document
          Clusterer::Document.new(acts_as_classifiable_options[:fields].collect{|field| self.send(field)}.join(" "))
        end
      end
    end
  end
end
