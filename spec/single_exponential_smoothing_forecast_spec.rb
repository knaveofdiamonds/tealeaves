require 'spec_helper'

describe TeaLeaves::SingleExponentialSmoothingForecast do
  before :each do
    @time_series = [1,2,3]
  end

  it "should generate one step ahead forecasts" do
    described_class.new(@time_series, 0.7).one_step_ahead_forecasts.
      should == [nil, 0.7 * 1 + 0.3 * 1, 0.7 * 2 + 0.3 * 1] 
  end

  it "has one step ahead errors" do
    described_class.new(@time_series, 0.7).errors.should == [nil, -1, -1.3]
  end

  it "has a predicition for the next period" do
    described_class.new(@time_series, 0.7).predict.should == 0.7 * 3 + 0.3 * 1.7
  end

  it "has a predicition for the n next periods" do
    described_class.new(@time_series, 0.7).predict(2).should == [0.7 * 3 + 0.3 * 1.7] * 2
  end

  it "calculates mean squared error" do
    described_class.new(@time_series, 0.7).mean_squared_error.should be_within(0.001).of(1.345)
  end
end
