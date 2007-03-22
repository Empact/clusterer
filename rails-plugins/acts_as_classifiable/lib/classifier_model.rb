# Schema as of Wed May 17 22:27:14 India Standard Time 2006 (schema version 12)
#
#  id                  :integer(11)   not null
#  identifier          :integer(11)   default(0), not null
#  classifiable_type   :string(10)    default(), not null
#  data                :binary
#

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

class ClassifierModel < ActiveRecord::Base
  attr_accessor :classifier
  before_save :dump_classifier

  def dump_classifier
    self.data = Marshal.dump(self.classifier)
  end

  def load_classifier
    self.classifier = Marshal.load(self.data)
  end
end
