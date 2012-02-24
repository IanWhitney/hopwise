require 'spec_helper'

describe Fermentable do
  it "should return weight in kilograms" do
    f = Fermentable.new({"AMOUNT" => "4.0"})
    f.weight.unit_name.should == :kilograms
  end
end