# Copyright (c) 2006 Surendra K. Singhi <ssinghi@kreeti.com>


require 'acts_as_clusterable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Clusterable)

require File.dirname(__FILE__) + '/lib/acts_as_clusterable'
