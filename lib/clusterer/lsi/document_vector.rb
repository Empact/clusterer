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

module Clusterer
  module DocumentVector
    module InstanceMethods
      attr_accessor :position
      
      def cosine_similarity(doc)
        return 1.0 unless doc# && doc.centroid
        self.inner_product((doc.class == DocumentsCentroidVector ? doc.centroid : doc)) #.transpose
      end
    end

    module ClassMethods
      def centroid_class
        DocumentsCentroidVector
      end
    end
  end
end

if $LINALG == true
  module Linalg
    class DMatrix
      include Clusterer::DocumentVector::InstanceMethods
      extend Clusterer::DocumentVector::ClassMethods
    end
  end
else
  class Vector
    include Clusterer::DocumentVector::InstanceMethods
    extend Clusterer::DocumentVector::ClassMethods
  end
end
