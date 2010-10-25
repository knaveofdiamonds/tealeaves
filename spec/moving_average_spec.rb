require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TeaLeaves::MovingAverage do
  it "should mix a #moving_average method into Array" do
    [0,1,2,6,4].moving_average(3).should == [1,3,4]
  end
end

describe "a Simple Moving Average" do
  it "should raise an ArgumentError if number of terms is < 1" do
    lambda { MovingAverage.simple(0) }.should raise_error(ArgumentError)
  end
  
  it "should have equal weights with an odd number of terms" do
    MovingAverage.simple(5).weights.should == [0.2, 0.2, 0.2, 0.2, 0.2]
  end
  
  it "should have have half weights at the ends with an even number of terms" do
    MovingAverage.simple(4).weights.should == [0.125, 0.25, 0.25, 0.25, 0.125]
  end

  it "should return 3 averages from #calculate with a 3 point MA over 5 terms" do
    MovingAverage.simple(3).calculate([0,1,2,6,4]).should == [1,3,4]
  end

  it "should return 1 average from #calculate with a 4 point MA over 5 terms" do
    MovingAverage.simple(4).calculate([0,1,2,6,4]).should == [2.75]
  end

  it "should return no averages from #calculate with a 7 point MA over 5 terms" do
    MovingAverage.simple(7).calculate([0,1,2,6,4]).should == []
  end
end

describe "a Weighted Moving Average" do
  it "should have symmetric weights by default when provided with half the list of weights" do
    MovingAverage.weighted([0.6, 0.3, 0.1]).weights == [0.1, 0.3, 0.6, 0.3, 0.1]
  end

  it "should have allow asymmetric weights" do
    MovingAverage.weighted([0.6, 0.3, 0.1], false).weights == [0.6, 0.3, 0.1]
  end
end
