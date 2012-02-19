require 'tealeaves/forecast'

module TeaLeaves
  class SingleExponentialSmoothingForecast < Forecast
    def initialize(time_series, alpha)
      @time_series = time_series
      @alpha = alpha

      @one_step_ahead_forecasts = [nil]

      ([@time_series.first] + @time_series).inject do |a,b|
        value = (1 - @alpha) * a + @alpha * b
        @one_step_ahead_forecasts << value
        value
      end

      @prediction = @one_step_ahead_forecasts.pop
    end

    def predict(n=nil)
      if n.nil?
        @prediction
      else
        [@prediction] * n
      end
    end
  end
end
