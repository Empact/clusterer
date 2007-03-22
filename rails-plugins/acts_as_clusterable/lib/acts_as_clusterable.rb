# Copyright (c) 2006 Surendra K. Singhi <ssinghi@kreeti.com>
require 'active_record'
require 'clusterer'

module ActiveRecord # :nodoc:
  module Acts #:nodoc:
    module Clusterable
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_clusterable(options = {})
          write_inheritable_attribute(:acts_as_clusterable_options, {
                                        :fields => (options[:fields] || self.content_columns.collect {|e|
                                                      e.name if e.type == :string || e.type == :text}.compact)
                                      })
          class_inheritable_reader :acts_as_clusterable_options
          extend ActiveRecord::Acts::Clusterable::SingletonMethods
        end
      end
      module SingletonMethods
        def cluster(options = { })
          Clusterer::Clustering.cluster(options[:algorithm] || :kmeans,
                                           self.find(:all, :conditions => options[:conditions]),
                                           options) {|inst|
            acts_as_clusterable_options[:fields].collect {|field| inst.send(field) }.join(" ")}
        end
      end
    end
  end
end
