require 'spec_helper'

describe Hop do
  it "should return given time if not a dry hop" do
    h = Hop.new({"USE" => "Aroma", "TIME" => "60"})
    h.time.should == 60
  end


  it "should return given time in days if a dry hop" do
    h = Hop.new({"USE" => "Dry Hop", "TIME" => "10080"})
    h.time.should == 7
  end
  
  it "should return weight in grams" do
    h = Hop.new({"AMOUNT" => "0.011"})
    h.weight.unit_name.should == :grams
    h.weight.should == 11.grams
  end
end