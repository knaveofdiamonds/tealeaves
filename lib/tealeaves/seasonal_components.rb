module TeaLeaves
  class SeasonalComponents
    def initialize(period, data)
      @period = period
      @data = data
    end

    def seasonal_averages
      @seasonal_averages ||= seasonal_groups.map do |group| 
        group.inject(&:+) / group.size.to_f
      end
    end
    
    def seasonal_factors(operation = :-)
      @seasonal_factors ||= seasonal_averages.map {|i| i.send(operation, avg) }
    end

    private

    def avg
      @avg ||= seasonal_averages.inject(&:+) / @period.to_f
    end

    def seasonal_groups
      @data.take(@period).zip( *(@data.drop(@period).each_slice(@period)) ).map(&:compact)
    end
  end
end
