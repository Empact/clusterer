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

require File.join(File.dirname(__FILE__), 'abstract_unit')
class ClassifiableTest < Test::Unit::TestCase
  fixtures :comments
  def test_instance_train_untrain_no_identifier_1
    @comment = comments(:hello)
    assert_not_nil @comment
    @comment.train(:good)
    @comment.train(:evil)
    assert_not_nil ClassifierModel.find_by_classifiable_type(Comment.to_s)
    @comment.untrain(:good)
    @comment.untrain(:evil)
    assert_not_nil ClassifierModel.find_by_classifiable_type(Comment.to_s)
  end

  def test_instance_train_untrain_no_identifier_2
    @comment = comments(:hello)
    assert_not_nil @comment
    @comment.train_good
    @comment.train_evil
    assert_not_nil ClassifierModel.find_by_classifiable_type(Comment.to_s)
    @comment.untrain_good
    @comment.untrain_evil
    assert_not_nil ClassifierModel.find_by_classifiable_type(Comment.to_s)
  end

  def test_instance_train_untrain_identifier_1
    @comment = comments(:hello)
    assert_not_nil @comment
    @comment.train(:good,1)
    @comment.train(:evil,1)
    assert_not_nil ClassifierModel.find_by_identifier(1)
    @comment.untrain(:good,1)
    @comment.untrain(:evil,1)
    assert_not_nil ClassifierModel.find_by_identifier(1)
  end

  def test_instance_train_untrain_identifier_2
    @comment = comments(:hello)
    assert_not_nil @comment
    @comment.train_good 1
    @comment.train_evil 1
    assert_not_nil ClassifierModel.find_by_identifier(1)
    @comment.untrain_good 1
    @comment.untrain_evil 1
  end

  def test_instance_classify_no_identifier
    @comment = comments(:hello)
    assert_not_nil @comment
    @comment.train_good
    @comment.train_evil
    assert_not_nil ClassifierModel.find_by_classifiable_type(Comment.to_s)
    @comment.distribution
    @comment.classify
  end

  def test_instance_train_classify_identifier_1
    @comment = comments(:hello)
    assert_not_nil @comment
    @comment.train(:good,1)
    @comment.train(:evil,1)
    assert_not_nil ClassifierModel.find_by_identifier(1)
    @comment.distribution
    @comment.classify
  end

  def test_instance_group_no_identifier
    Comment.train [comments(:hello), comments(:bye)], [:good, :evil]
    assert_not_nil ClassifierModel.find_by_classifiable_type(Comment.to_s)
    comments(:hello).distribution
    comments(:hello).classify
    Comment.untrain [comments(:hello), comments(:bye)], [:good, :evil]
    comments(:hello).distribution
    comments(:hello).classify
  end

  def test_instance_group_identifier_1
    Comment.train [comments(:hello), comments(:bye)], [:good, :evil], 10
    assert_not_nil ClassifierModel.find_by_classifiable_type(Comment.to_s)
    assert_equal 10, ClassifierModel.find_by_classifiable_type(Comment.to_s).identifier
    comments(:hello).distribution 10
    comments(:hello).classify 10
    Comment.untrain [comments(:hello), comments(:bye)], [:good, :evil], 10
    assert_equal 2, Comment.distribution([comments(:hello), comments(:bye)], 10).size
    assert_equal 2, Comment.classify([comments(:hello), comments(:bye)], 10).size
  end
end
