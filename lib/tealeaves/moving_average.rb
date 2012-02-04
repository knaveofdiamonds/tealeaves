module TeaLeaves  
  # A calculator for simple & weighted moving averages.
  class MovingAverage
    attr_reader :weights, :number_of_terms

    # Returns a Weighted Moving Average calculator, given a list of
    # weights. 
    #
    # The list of weights should be an odd length, and should sum to
    # 1.
    #
    # Examples:
    #
    #    MovingAverage.weighted([0.15, 0.7, 0.15]) # => [0.2, 0.7, 0.1]
    #
    def self.weighted(weights)
      new(weights)
    end

    # Returns a Simple Moving Average calculator, given a span n.
    # 
    # Examples:
    #  
    #    MovingAverage.simple(5).weights # => [0.2, 0.2, 0.2, 0.2, 0.2]
    #
    # @param [Integer] n the span or order of the moving average,
    #   i.e. the number of terms to include in each average.
    def self.simple(n)
      raise ArgumentError.new("Number of terms must be positive") if n < 1
      weights = n.odd?() ? [1.0 / n] * n : expand_weights([1.0 / n] * (n / 2) + [1.0 / (2 * n)])
      new weights
    end


    # Returns a moving average of a moving average calculator.
    #
    # For Example, for a 3x3 MA:
    # 
    #     MovingAverage.multiple(3,3).weights #=> [1/9, 2/9, 1/3, 2/9, 1/9]
    #
    def self.multiple(m,n)
      divisor = (m * n).to_f
      weights = (1..m).map {|i| i / divisor }
      num_of_center_weights = ((m + n) / 2) - m
      num_of_center_weights = 0 if num_of_center_weights < 0
      num_of_center_weights.times { weights << weights.last }
      
      new(expand_weights(weights.reverse))
    end

    # Creates a new MovingAverage given a list of weights.
    #
    # See also the class methods simple and weighted.
    def initialize(weights)
      @weights = weights
      @span = @weights.length
      @each_side = @span / 2
      check_weights
    end
    
    # Calculates the moving average for the given array of numbers.
    #
    # Moving averages won't include values for terms at the beginning or end of
    # the array, so there will be fewer numbers than in the original.
    def calculate(array)
      return [] if @span > array.length
      
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

    # Error checking for weights
    def check_weights
      raise ArgumentError.new("Weights should be an odd list") unless @span.odd?
      sum = weights.inject(&:+)
      if sum < 0.999999 || sum > 1.000001
        raise ArgumentError.new("Weights must sum to 1")
      end
    end

    def self.expand_weights(weights)
      left_side_weights = weights.reverse
      left_side_weights.pop
      left_side_weights + weights
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
