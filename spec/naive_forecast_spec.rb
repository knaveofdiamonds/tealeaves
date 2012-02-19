require 'spec_helper'

describe TeaLeaves::NaiveForecast do
  before :each do
    @time_series = [1,2,3]
  end

  it "provides forecasts such that F_t+1 = Y_t" do
    described_class.new(@time_series).one_step_ahead_forecasts.should == [nil, 1, 2]
  end

  it "returns errors between one step ahead forecasts and observed values" do
    described_class.new(@time_series).errors.should == [nil, -1, -1]
  end

  it "returns a prediction for the next value in the series" do
    described_class.new(@time_series).predict.should == 3
  end

  it "returns n predictions for the next values, all the same" do
    described_class.new(@time_series).predict(4).should == [3,3,3,3]
  end

  it "returns 1 as Thiel's U Statistic" do
    described_class.new(@time_series).u_statistic.should == 1
  end
end
