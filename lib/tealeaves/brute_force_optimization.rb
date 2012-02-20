module TeaLeaves
  class BruteForceOptimization
    INITIAL_PARAMETER_VALUES = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0].freeze
    
    def initialize(time_series, period, opts={})
      @time_series = time_series
      @period = period
      @opts = opts
    end


    def optimize
      [0.1, 0.5, 0.25, 0.125, 0.0625, 0.03125, 0.015625].inject(optimum(initial_models)) do |model, change|
        improve_model(model, change)
      end
    end

    def initial_test_parameters(opts={})
      parameters = []
      INITIAL_PARAMETER_VALUES.each do |alpha|
        parameters << {:alpha => alpha, :seasonality => :none, :trend => :none}
        
        unless opts[:seasonality] == :none && opts[:trend] == :none
          INITIAL_PARAMETER_VALUES.each do |b|
            parameters << {:alpha => alpha, :beta => b, :seasonality => :none, :trend => :additive}
            parameters << {:alpha => alpha, :beta => b, :seasonality => :none, :trend => :multiplicative}
            parameters << {:alpha => alpha, :gamma => b, :trend => :none, :seasonality => :additive}
            parameters << {:alpha => alpha, :gamma => b, :trend => :none, :seasonality => :multiplicative}
            
            INITIAL_PARAMETER_VALUES.each do |gamma|
              [:additive, :multiplicative].each do |trend|
                [:additive, :multiplicative].each do |seasonality|
                  parameters << {
                    :alpha => alpha,
                    :beta => b,
                    :gamma => gamma,
                    :trend => trend,
                    :seasonality => seasonality
                  }
                end
              end
            end
          end
        end
      end

      parameters
    end

    private

    def improve_model(model, change)
      trend_operations = model.trend == :none ? [nil] : [:+, :-, nil]
      season_operations = model.seasonality == :none ? [nil] : [:+, :-, nil]
      permutations = [:+, :-, nil].product(trend_operations, season_operations)
      optimum(permutations.map do |(op_1,op_2,op_3)|
                new_opts = {}
                set_value(new_opts, :alpha, model, op_1, change)
                set_value(new_opts, :beta, model, op_2, change)
                set_value(new_opts, :gamma, model, op_3, change)
                model.improve(new_opts)
              end)
    end

    def set_value(hsh, key, model, op, change)
      unless op.nil?
        new_value = model.send(key).send(op, change)
        if new_value >= 0.0 && new_value <= 1.0
          hsh[key] = new_value
        end
      end
    end

    def optimum(models)
      models.min_by(&:mean_squared_error)
    end
    
    def initial_models
      initial_test_parameters.map do |parameters|
        ExponentialSmoothingForecast.new(@time_series, @period, parameters)
      end
    end
  end
end
