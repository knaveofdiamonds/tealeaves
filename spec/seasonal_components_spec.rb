require 'spec_helper'

describe TeaLeaves::SeasonalComponents do
  it "returns seasonal averages for a period" do
    described_class.new(4, [1,2,1,3,2,4,1,9]).seasonal_averages.
      should == [1.5, 3, 1, 6]
  end

  it "returns seasonal averages for a period, with ragged data" do
    described_class.new(4, [1,2,1,3,2,4,1,9, 3]).seasonal_averages.
      should == [2, 3, 1, 6]
  end

  it "returns seasonal weights" do
    described_class.new(4, [1,2,1,3,2,4,1,9,3]).seasonal_factors.
      should == [-1.0, 0.0, -2.0, 3.0]
  end
end
