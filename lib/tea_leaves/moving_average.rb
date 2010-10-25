module TeaLeaves  
  # A calculator for simple & weighted moving averages.
  class MovingAverage
    attr_reader :weights, :number_of_terms

    class << self
      # Returns a Weighted Moving Average calculator, given a list of
      # weights. 
      #
      # By default the weights are assumed to be symmetric and are
      # reflected (so you don't need to repeat weights). If symmetric
      # is false then the weights are assumed to be complete.
      #
      # Examples:
      #
      #    MovingAverage.weighted([0.6, 0.2]).weights # => [0.2, 0.6, 0.2]
      #    MovingAverage.weighted([0.2, 0.7, 0.1], false) # => [0.2, 0.7, 0.1]
      def weighted(weights, symmetric=true)
        new(symmetric ? expand_weights(weights) : weights)
      end

      # Returns a Simple Moving Average calculator, given a number of
      # terms/points to average over.
      # 
      # Examples:
      #  
      #    MovingAverage.simple(5).weights # => [0.2, 0.2, 0.2, 0.2, 0.2]
      # 
      def simple(n)
        raise ArgumentError.new("Number of terms must be positive") if n < 1
        weights = n.odd?() ? [1.0 / n] * n : expand_weights([1.0 / n] * (n / 2) + [1.0 / (2 * n)])
        new weights
      end

      def multiple(m,n)
        divisor = (m * n).to_f
        weights = (1..m).map {|i| i / divisor }
        extra_right_terms = ((m + n) / 2) - m
        extra_right_terms = 0 if extra_right_terms < 0
        extra_right_terms.times { weights << weights.last }

        new(expand_weights(weights.reverse))
      end

      private

      def expand_weights(weights)
        left_side_weights = weights.reverse
        left_side_weights.pop
        left_side_weights + weights
      end
    end

    # Creates a new MovingAverage given a list of weights.
    #
    # See also the class methods simple and weighted.
    def initialize(weights)
      @weights = weights
      @number_of_terms = @weights.length
      @each_side = @weights.length / 2
    end
    
    # Calculates the moving average for the given array of numbers.
    #
    # Moving averages cannot include terms at the beginning or end of
    # the array, so there will be fewer numbers than in the original array.
    def calculate(array)
      return [] if number_of_terms > array.length
      
      (@each_side...(array.length - @each_side)).map do |i|
        array[window(i)].zip(weights).map {|(a,b)| a * b }.inject {|a, b| a + b }
      end
    end
    
    private
    
    # Returns a sliding window of indexes based on a center index, i
    # and the number of terms.
    def window(i)
      (i - @each_side)..(i + @each_side)
    end
  end

  module ArrayMethods
    # Returns a moving average for this array, given either a number
    # of terms or a half-list of weights (so the weights will be
    # symmetric).
    #
    # See MovingAverage for more detail.
    # 
    def moving_average(average_specifier)
      return self if average_specifier == 1

      if average_specifier.kind_of?(Array)
        avg = MovingAverage.weighted(average_specifier)
      elsif average_specifier.kind_of?(Integer)
        avg = MovingAverage.simple(average_specifier)
      else
        raise ArgumentError.new("Unknown weights")
      end
      
      avg.calculate(self)
    end
  end
end

Array.send(:include, TeaLeaves::ArrayMethods)
