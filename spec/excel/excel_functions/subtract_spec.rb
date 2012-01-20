require_relative '../../spec_helper.rb'

describe "ExcelFunctions: subtract(number,number)" do
  
  it "should return sum of its arguments" do
    FunctionTest.subtract(2,1).should == 1
    FunctionTest.subtract(2.0,1.0).should == 1
  end
    
  it "should treat nil as zero" do
    FunctionTest.subtract(1,nil).should == 1
    FunctionTest.subtract(nil,nil).should == 0
    FunctionTest.subtract(nil,1).should == -1
  end
  
  it "should return an error if either argument is an error" do
    FunctionTest.subtract(:error,1).should == :error
    FunctionTest.subtract(1,:error).should == :error
    FunctionTest.subtract(:error1,:error2).should == :error1
  end
  
end