module TeaLeaves
  class Forecast
    # Returns an array of 1 step ahead forecasts. The initial value in
    # this array will be nil - there is no way of predicting the first
    # value of the series.
    attr_reader :one_step_ahead_forecasts

    # Returns the errors between the observed values and the one step
    # ahead forecasts.
    def errors
      @errors ||= @time_series.zip(one_step_ahead_forecasts).map do |(observation, forecast)|
        forecast - observation if forecast && observation
      end
    end

    # Returns the mean squared error of the forecast.
    def mean_squared_error
      numerator = errors.drop(1).map {|i| i ** 2 }.inject(&:+)
      numerator / (errors.size - 1).to_f
    end
  end
end
