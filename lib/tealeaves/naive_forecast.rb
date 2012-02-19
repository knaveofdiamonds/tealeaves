require 'tealeaves/forecast'

module TeaLeaves
  # A naive model just uses the current period's value as the
  # prediction for the next period, i.e. F_t+1 = Y_t
  class NaiveForecast < Forecast
    # Creates a naive forecasting model for the given time series.
    def initialize(time_series)
      @time_series = time_series
      @one_step_ahead_forecasts = [nil] + time_series
      @one_step_ahead_forecasts.pop
    end

    # Returns Thiel's U Statistic. By definition, this is 1 for the
    # Naive method.
    def u_statistic
      1
    end

    # Returns a prediction for the next period, or for the next n
    # periods.
    def predict(n=nil)
      if n.nil?
        @time_series.last
      else
        [@time_series.last] * n
      end
    end
  end
end
