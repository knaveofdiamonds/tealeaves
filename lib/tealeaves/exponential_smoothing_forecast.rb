require 'tealeaves/forecast'

module TeaLeaves
  class ExponentialSmoothingForecast < Forecast
    class SeasonalityStrategy
      attr_reader :start_index

      def initialize(period, gamma)
        @gamma = gamma
        @start_index = period
      end

      def new_values(observed_value, parameters, new_level)
        new_seasonality = @gamma * t(observed_value, new_level) + 
          (1 - @gamma) * parameters[:seasonality].first
        parameters[:seasonality].drop(1) << new_seasonality
      end
    end

    class AdditiveSeasonalityStrategy < SeasonalityStrategy
      def p(value, params)
        value - params[:seasonality].first
      end

      def t(value, new_level)
        value - new_level
      end

      def apply(forecast, parameters, n)
        index = (n - 1) % parameters[:seasonality].size
        forecast + parameters[:seasonality][index]
      end
    end

    class MultiplicativeSeasonalityStrategy < SeasonalityStrategy
      def p(value, params)
        value / params[:seasonality].first
      end

      def t(value, new_level)
        value / new_level
      end

      def apply(forecast, parameters, n)
        index = (n - 1) % parameters[:seasonality].size
        forecast * parameters[:seasonality][index]
      end
    end
    
    class NoSeasonalityStrategy < SeasonalityStrategy
      def p(value, params)
        value
      end

      def t(value, new_level)
      end
      
      def new_values(*args)
        []
      end

      def start_index
        1
      end

      def apply(forecast, parameters)
        forecast
      end
    end

    def initialize(time_series, period, opts={})
      @time_series = time_series
      @period = period
      @alpha = opts[:alpha]
      @beta  = opts[:beta]
      @trend = opts[:trend]
      @seasonality = opts[:seasonality]
      @seasonality_strategy = case @seasonality
                              when :none
                                NoSeasonalityStrategy.new(@period, opts[:gamma])
                              when :additive
                                AdditiveSeasonalityStrategy.new(@period, opts[:gamma])
                              when :multiplicative
                                MultiplicativeSeasonalityStrategy.new(@period, opts[:gamma])
                              end

      calculate_one_step_ahead_forecasts
    end

    attr_reader :model_parameters

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
        :index => @seasonality_strategy.start_index
      }
    end

    def predict(n=nil)
      if n.nil?
        forecast(@model_parameters)
      else
        (1..n).map {|i| forecast(@model_parameters, i).first }
      end
    end

    private

    def calculate_one_step_ahead_forecasts
      forecasts = [nil] * @seasonality_strategy.start_index
      parameters = initial_parameters
      (@seasonality_strategy.start_index...@time_series.size).each do |i|
        forecast, parameters = forecast(parameters)
        forecasts << forecast
      end
      parameters[:index] -= 1
      @model_parameters = parameters
      @one_step_ahead_forecasts = forecasts
    end

    def forecast(parameters, n=1)
      new_params = {}
      new_params[:level] = new_level(parameters)
      new_params[:trend] = new_trend(parameters, new_params[:level])
      new_params[:seasonality] = new_seasonality(parameters, new_params[:level])
      new_params[:index] = parameters[:index] + 1
      
      pre_forecast = case @trend
                     when :none
                       parameters[:level]
                     when :additive
                       parameters[:level] + (n * parameters[:trend])
                     when :multiplicative
                       parameters[:level] * (parameters[:trend] ** n)
                     end

      forecast = @seasonality_strategy.apply(pre_forecast, parameters, n)
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
      @seasonality_strategy.new_values(@time_series[parameters[:index]],
                                       parameters,
                                       new_level)
    end

    def p(params)
      @seasonality_strategy.p(@time_series[params[:index]], params)
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
  end
end
