module TeaLeaves
  class MovingAverage
    attr_reader :weights, :number_of_terms

    class << self
      # Returns a moving average object given a number of terms, a
      # specialized weighting method symbol or an array of weights.
      #
      # 
      def get(average_specifier)
        if average_specifier.kind_of?(Array)
          weighted(average_specifier)
        elsif average_specifier.kind_of?(Integer)
          simple(average_specifier)
        else
          raise ArgumentError.new("Unknown weights")
        end
      end
      
      def weighted(weights)
        new expand_weights(weights)
      end

      def simple(n)
        raise ArgumentError.new("Number of terms must be positive") if n < 1
        
        if n.odd?
          weights = [1.0 / n] * ((n / 2) + 1)
        else
          weights = [1.0 / n] * (n / 2) + [1.0 / (2 * n)]
        end

        new expand_weights(weights)
      end

      private

      def expand_weights(weights)
        left_side_weights = weights.clone
        left_side_weights.shift
        left_side_weights.reverse + weights
      end
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
