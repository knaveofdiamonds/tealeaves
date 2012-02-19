require 'tealeaves/forecast'

module TeaLeaves
  class ExponentialSmoothingForecast < Forecast
    def initialize(time_series, period, opts={})
      @time_series = time_series
      @period = period
      @alpha = opts[:alpha]
      @beta  = opts[:beta]
      @gamma = opts[:gamma]
      @trend = opts[:trend]
      @seasonality = opts[:seasonality]
    end

    def initial_level
      @initial_level ||= @time_series.take(@period).inject(&:+).to_f / @period
    end

    def initial_trend
      period_1, period_2 = @time_series.each_slice(@period).take(2)
      period_1.zip(period_2).map {|(a,b)| (b - a) / @period.to_f }.inject(&:+) / @period
    end

    def initial_seasonal_indices
      operation = @seasonality == :multiplicative ? :/ : :-
      @time_series.take(@period).map {|v| v.to_f.send(operation, initial_level) }
    end

    def initial_parameters
      { :level => initial_level,
        :trend => initial_trend,
        :seasonality => initial_seasonal_indices,
        :index => @period
      }
    end

    def one_step_ahead_forecasts
      forecasts = [nil] * @period
      parameters = initial_parameters
      (@period...@time_series.size).each do |i|
        forecast, parameters = forecast(parameters)
        forecasts << forecast
      end
      forecasts
    end

    def forecast(parameters)
      new_params = {}
      new_params[:level] = new_level(parameters)
      new_params[:trend] = new_trend(parameters, new_params[:level])
      new_params[:seasonality] = new_seasonality(parameters, new_params[:level])
      new_params[:index] = parameters[:index] + 1
      
      pre_forecast = case @trend
                     when :none
                       parameters[:level]
                     when :additive
                       parameters[:level] + parameters[:trend]
                     when :multiplicative
                       parameters[:level] * parameters[:trend]
                     end

      forecast = case @seasonality
                 when :none
                   pre_forecast
                 when :additive
                   pre_forecast + parameters[:seasonality].first
                 when :multiplicative
                   pre_forecast * parameters[:seasonality].first
                 end

      [forecast, new_params]
    end

    def new_level(parameters)
      @alpha * p(parameters) + (1 - @alpha) * q(parameters)
    end

    def new_trend(parameters, new_level)
      unless @trend == :none
        @beta * r(parameters, new_level) + (1 - @beta) * parameters[:trend]
      end
    end

    def new_seasonality(parameters, new_level)
      unless @seasonality == :none
        new_seasonality = @gamma * t(parameters, new_level) + (1 - @gamma) * parameters[:seasonality].first
        parameters[:seasonality].drop(1) << new_seasonality
      end
    end

    def p(params)
      case @seasonality
      when :none
        @time_series[params[:index]]
      when :additive
        @time_series[params[:index]] - params[:seasonality][0]
      when :multiplicative
        @time_series[params[:index]] / params[:seasonality][0]
      end
    end

    def q(params)
      case @trend
      when :none
        params[:level]
      when :additive
        params[:level] + params[:trend]
      when :multiplicative
        params[:level] * params[:trend]
      end
    end

    def r(params, new_level)
      case @trend
      when :additive
        new_level - params[:level]
      when :multiplicative
        new_level / params[:level]
      end
    end

    def t(params, new_level)
      case @seasonality
      when :additive
        @time_series[params[:index]] - new_level
      when :multiplicative
        @time_series[params[:index]] / new_level
      end
    end
  end
end
