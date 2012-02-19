require 'spec_helper'

describe TeaLeaves::ExponentialSmoothingForecast do
  before :each do
    @time_series = [1,2,3,5,
                    3,4,5,8,
                    6,7,8,10]
    @options  = {
      :seasonality => :additive,
      :trend => :additive,
      :alpha => 0.9,
      :beta => 0.9,
      :gamma => 0.0
    }
    @forecast = described_class.new(@time_series, 4, @options)
  end

  it "should have an initial level of 11 / 4" do
    @forecast.initial_level.
      should be_within(0.001).of(11.0 / 4.0)
  end

  it "should have an initial trend" do
    @forecast.initial_trend.
      should be_within(0.0001).of(0.5625)
  end

  # [1 / (11/4.0), 2 / (11/4.0), 3 / (11/4.0), 5 / (11/4.0)]
  it "should have initial seasonal indices for additive seasonality" do
    @forecast.initial_seasonal_indices.should == [1 - (11/4.0), 2 - (11/4.0), 3 - (11/4.0), 5 - (11/4.0)]
  end

  it "should have initial seasonal indices for additive seasonality" do
    @options[:seasonality] = :multiplicative
    @forecast = described_class.new(@time_series, 4, @options)
    @forecast.initial_seasonal_indices.should == [1 / (11/4.0), 2 / (11/4.0), 3 / (11/4.0), 5 / (11/4.0)]
  end

  it "should generate forecasts" do
    data = [362,
            385,
            432,
            341,
            382,
            409,
            498,
            387,
            473,
            513,
            582,
            474]

    @forecast = described_class.new(data, 4, 
                                    :alpha => 0.822,
                                    :beta  => 0.055,
                                    :gamma => 0.0,
                                    :trend => :additive,
                                    :seasonality => :multiplicative)

    @forecast.initial_level.should == 380
    @forecast.initial_trend.should == 9.75
    @forecast.initial_seasonal_indices.zip([0.953, 1.013, 1.137, 0.897]).each do |(observed, expected)|
      observed.should be_within(0.001).of(expected)
    end

    expected_values = [371.29, 414.64, 471.43, 399.3, 423.11, 506.60, 589.26, 471.93]
    @forecast.one_step_ahead_forecasts.drop(4).zip(expected_values).each do |(observed, expected)|
      observed.should be_within(0.03).of(expected)
    end
  end
end
