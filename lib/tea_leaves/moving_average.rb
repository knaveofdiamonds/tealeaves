module TeaLeaves
  class MovingAverage
    attr_reader :weights, :number_of_terms

    # Returns a moving average object given a number of terms, a
    # specialized weighting method symbol or an array of weights.
    #
    # 
    def self.get(average_specifier)
      if average_specifier.kind_of?(Array)
        weights = average_specifier
      elsif average_specifier.kind_of?(Integer)
        raise ArgumentError.new("Number of terms must be positive") if average_specifier < 1
        
        if average_specifier.odd?
          weights = [1.0 / average_specifier] * (((average_specifier) / 2) + 1)
        else
          weights = [1.0 / average_specifier] * ((average_specifier) / 2) + [1.0 / (2 * average_specifier)]
        end
      else
        raise ArgumentError.new("Unknown weights")
      end

      left_side_weights = weights.clone
      left_side_weights.shift

      new(left_side_weights.reverse + weights)
    end

    def initialize(weights)
      @weights = weights
      @number_of_terms = @weights.length
      @each_side = @weights.length / 2
    end
    
    def calculate(array)
      return [] if number_of_terms > array.length
      
      (@each_side...(array.length - @each_side)).map do |i|
        array[window(i)].zip(weights).map {|(a,b)| a * b }.inject {|a, b| a + b }
      end
    end
    
    private
    
    def window(i)
      (i - @each_side)..(i + @each_side)
    end
  end

  module ArrayMethods
    def moving_average(average_specifier)
      return self if average_specifier == 1
      MovingAverage.get(average_specifier).calculate(self)
    end
  end
end

Array.send(:include, TeaLeaves::ArrayMethods)
