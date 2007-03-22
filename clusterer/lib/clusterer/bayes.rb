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
  #The class Bayes is the base class for implementing different types of Naive
  #Bayes classifier. The initialize method of this class is protected, so objects
  #of this class cannot be instantiated.
  #The Bayesian Formula is P(y|x) = P(x/y) * P(y) / P(x)
  # posterior = likelhood * prior / evidence
  #Given the evidence, we have to predict the posterior. The different Bayesian variants
  #given below calculate likelihood using different methods.
  #While calculating the posterior since the evidence value is same for all the categories, this
  #values is not calculated. Also, posterior distribution over all possible categories sum upto 1.
  class Bayes
    #an attribute for storing the different types of classes or categories
    attr_accessor :categories

    protected
    #The first argument is an Array of categories. Currently no options are supported.
    def initialize(categories, options = { })
      @prior_count = Hash.new       #stores the number of document of diffrent classes/categories.
      @categories = categories.collect {|c| c.to_sym }
      @likelihood_numer = Hash.new    #hash of hash for storing the numerator in the likelihood value for each class
      @likelihood_denom = Hash.new    #hash of hash for storing the denominator in the likelihood value for each class
      @documents_count = 0  #total number of documents
      @categories.each {|cl| @likelihood_numer[cl] = Hash.new; @likelihood_denom[cl] = 0.0; @prior_count[cl] = 0}
    end

    #The first argument is the document, which will be used for training, and the
    #second is the category.
    def train(document, category)
      check_class(category)
      @prior_count[category] +=1
      @documents_count += 1
    end

    #The first argument is the document, which should be removed, and the
    #second is the category to which it belonged.
    def untrain(document, category)
      check_class(category)
      raise StandardError, "There are no documents for this class.",caller if @prior_count[category] <= 0
      @prior_count[category] -= 1
      @documents_count -= 1
    end

    #For an input document returns the probability distribution of the different
    #categories in the same order as the order in categories array.
    def distribution
      posterior = Array.new(@categories.size,0.0)
      @categories.each_with_index do |cl,ind|
        posterior[ind] = yield(cl,ind) + Math.log((@prior_count[cl] + 1)/(@documents_count + 1).to_f)
      end
      sum = 0
      posterior.each_with_index {|v,i| posterior[i] = Math.exp(v); sum += posterior[i]}
      posterior.each_with_index {|v,i| posterior[i] /= sum}
      posterior
    end

public
    #For an input document returns the prediction in favor of class with the
    #highest probability.
    def classify(document, weight = nil)
      posterior = distribution(document)
      @categories[(0..(@categories.size - 1)).max {|i,j| posterior[i] <=> posterior[j]}]
    end

    #This method missing helps in having training and untraining method which have the
    #category appended to their front. For example:
    #
    #    train_good document
    #
    def method_missing (name, *args)
      if name.to_s =~ /^(un)?train_/
        category = name.to_s.gsub(/(un)?train_/, '').to_sym
        send("#{$1}train",args[0],category)
       else
        super
      end
    end

    private
    def check_class(category)
      raise ArgumentError,"Unknown class. It should be one of the following #{categories}.",caller unless categories.include?(category)
    end
  end

  #Based on the description given in "Tackling the Poor Assumptions of Naive Bayes Text Classifiers"
  #by Jason D. M. Rennie, Lawrence Shih, Jaime Teevan and David R. Karger, ICML - 2003
  #
  #The basic idea is that likelihood of a document for certain category is directly proportional to
  #the number of other documents containing the same terms appearing while training for the
  #particular class.
  class MultinomialBayes < Bayes
    def train(document, category)
      category = category.to_sym
      super
      numer, sum = @likelihood_numer[category], 0.0
      document.each do |term,freq|
        numer[term] = (numer[term] || 0) + freq
        sum += freq
      end
      @likelihood_denom[category] += sum
    end

    def untrain(document, category)
      category = category.to_sym
      super
      numer, sum = @likelihood_numer[category], 0.0
      document.each do |term,freq|
        if numer[term]
          numer[term] = [numer[term] - freq, 0].max
          sum += freq
        end
      end
      @likelihood_denom[category] = [@likelihood_denom[category] - sum, 0.0].max
    end

    def distribution(document)
      super() do |cl,ind|
        numer, denom, sum = @likelihood_numer[cl], (1 + @likelihood_denom[cl]), 0.0
        document.each {|term,freq| sum += freq * Math.log((1 + (numer[term] || 0))/denom)}
        sum
      end
    end
  end

  #Based on the description given in "Tackling the Poor Assumptions of Naive Bayes Text Classifiers"
  #by Jason D. M. Rennie, Lawrence Shih, Jaime Teevan and David R. Karger, ICML - 2003
  #
  #The idea is that likelihood of a document for certain category is inversely proportional to
  #the number of other documents containing the same terms appearing in other classes. Notice, the
  #difference with MultiNomialBayes, and hence it is called complement.
  #Though the authors claim that this performs better than MultiNomialBayes, but take the results
  #with a pinch of salt, the performance of MultiNomial may be better with balanced datasets.
  #If the dataset is skewed with the minority class being important, use ComplementBayes.
  class ComplementBayes < Bayes
    def train(document, category)
      category = category.to_sym
      super
      (@categories - [category]).each_with_index do |cl,ind|
        numer, sum = @likelihood_numer[cl], 0.0
        document.each do |term,freq|
          numer[term] = (numer[term] || 0) + freq
          sum += freq
        end
        @likelihood_denom[cl] += sum
      end
    end

    def untrain(document, category)
      category = category.to_sym
      super
      (@categories - [category]).each_with_index do |cl,ind|
        numer, sum = @likelihood_numer[category], 0.0
        document.each do |term,freq|
          if numer[term]
            numer[term] = [numer[term] - freq, 0].max
            sum += freq
          end
        end
        @likelihood_denom[category] = [@likelihood_denom[category] - sum, 0.0].max
      end
    end

    def distribution(document)
      super() do |cl,ind|
        numer, denom, sum = @likelihood_numer[cl], (1 + @likelihood_denom[cl]), 0.0
        document.each {|term, freq| sum += freq * Math.log((1 + (numer[term] || 0))/denom)}
        -sum
      end
    end
  end

  ##Module to help in implementing weighted form of MultimonialBayes and ComplementBayes.
  ##For performance reasons the normalized classifier weights are cached. These weights
  #are calculated only when the classifier is first used for training or prediction.
  #Training or Untraining an instance clears the cached normalized weights.
  module WeightNormalized
    def initialize(categories, options = { })
      super
      @weighted_likelihood = Hash.new
    end

    def train(document, category)
      super
      @weighted_likelihood.clear
    end

    def untrain(document, category)
      super
      @weighted_likelihood.clear
    end

    private
    def weighted_likelihood(category)
      @weighted_likelihood[category] ||= begin
                                           sum, le, denom = 0.0, Hash.new, (1 + @likelihood_denom[category])
                                           numer =
                                           @likelihood_numer[category].each do |term,freq|
                                             le[term] = Math.log((1 + freq)/denom)
                                             sum += le[term]
                                           end
                                           le.each {|term, weight| le[term] = weight/sum }
                                         end
    end
  end

  #Based on the description given in "Tackling the Poor Assumptions of Naive Bayes Text Classifiers"
  #by Jason D. M. Rennie, Lawrence Shih, Jaime Teevan and David R. Karger, ICML - 2003
  #
  #An improved complement bayes, the authors claim that this algorithm performs better, then the
  #ComplementBayes. The weights are normalized, before using this algorithm.
  class WeightNormalizedComplementBayes < ComplementBayes
    include WeightNormalized
    def distribution(document)
      self.class.superclass.superclass.instance_method(:distribution).bind(self).call do |cl,ind|
        we, sum = weighted_likelihood(cl), 0.0
        document.each {|term,freq| sum += freq * (we[term] || 0)}
        -sum
      end
    end
  end

  #Hopefully an improved MultinomialBayes, based on the same ideas as the WeightNormalizedComplementBayes
  #only using MultinomialBayes as the base. The weights are normalized, before using this algorithm.
  class WeightNormalizedMultinomialBayes < MultinomialBayes
    include WeightNormalized
    def distribution(document)
      self.class.superclass.superclass.instance_method(:distribution).bind(self).call do |cl,ind|
        we, sum = weighted_likelihood(cl), 0.0
        document.each {|term,freq| sum += freq * (we[term] || 0)}
        sum
      end
    end
  end
end
