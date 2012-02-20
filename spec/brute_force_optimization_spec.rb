require 'spec_helper'

describe TeaLeaves::BruteForceOptimization do
  it "should have 1014 initial test models" do
    described_class.new([1,2,3,4], 1).initial_test_parameters.size.should == 1014
  end

  it "should produce an initial model" do

  end
end
