require 'tealeaves/moving_average'
require 'tealeaves/seasonal_components'
require 'tealeaves/forecast'
require 'tealeaves/naive_forecast'
require 'tealeaves/single_exponential_smoothing_forecast'
require 'tealeaves/brute_force_optimization'
require 'tealeaves/exponential_smoothing_forecast'

module TeaLeaves
  def self.optimal_model(time_series, period)
    BruteForceOptimization.new(time_series, period).optimize
  end

  def self.forecast(time_series, period, periods_ahead=nil)
    optimal_model(time_series, period).predict(periods_ahead)
  end
end
