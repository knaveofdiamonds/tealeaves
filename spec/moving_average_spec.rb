require 'spec_helper'

describe TeaLeaves::MovingAverage do
  it "should mix a #moving_average method into Array that takes a span" do
    [0,1,2,6,4].moving_average(3).should == [1,3,4]
  end

  it "should mix a #moving_average method into Array that takes weights" do
    [0,1,2,6,4].moving_average([0.2,0.6,0.2]).should == [1.0, 2.6, 4.8]
  end

  describe "a Simple Moving Average" do
    it "should raise an ArgumentError if number of terms is < 1" do
      lambda { described_class.simple(0) }.should raise_error(ArgumentError)
    end
    
    it "should have equal weights with an odd number of terms" do
      described_class.simple(5).weights.should == [0.2, 0.2, 0.2, 0.2, 0.2]
    end
    
    it "should have have half weights at the ends with an even number of terms" do
      described_class.simple(4).weights.should == [0.125, 0.25, 0.25, 0.25, 0.125]
    end
    
    it "should return 3 averages from #calculate with a 3 point MA over 5 terms" do
      described_class.simple(3).calculate([0,1,2,6,4]).should == [1,3,4]
    end
    
    it "should return 1 average from #calculate with a 4 point MA over 5 terms" do
      described_class.simple(4).calculate([0,1,2,6,4]).should == [2.75]
    end
    
    it "should return no averages from #calculate with a 7 point MA over 5 terms" do
      described_class.simple(7).calculate([0,1,2,6,4]).should == []
    end
  end

  describe "a Weighted Moving Average" do
    it "raises an Argument error if the weights do not sum to 1" do
      expect { described_class.weighted([0.5, 0.5, 0.1]) }.to raise_error(ArgumentError)
    end

    it "raises an Argument error if the list of weights is not odd sized" do
      expect { described_class.weighted([0.5, 0.5]) }.to raise_error(ArgumentError)
    end
        
    it "should allow asymmetric weights" do
      described_class.weighted([0.6, 0.3, 0.1]).weights == [0.6, 0.3, 0.1]
    end
  end

  describe "a Mutliple Moving Average" do
    it "should combine weights in the 3x3 case" do
      described_class.multiple(3,3).weights.should == [1.0/9, 2.0/9, 3.0/9, 2.0/9, 1.0/9]
    end
    
    it "should combine weights in the 3x5 case" do
      described_class.multiple(3,5).weights.should == [1.0/15, 2.0/15, 0.2, 0.2, 0.2, 2.0/15, 1.0/15]
    end
  end
end
