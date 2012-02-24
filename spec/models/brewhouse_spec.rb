require 'spec_helper'

describe Brewhouse do
  it "should return fermenter loss in litres" do
    Brewhouse.fermenter_loss.unit_name.should == :litres
  end
  
  it "should return maximum kettle volume in litres" do
    Brewhouse.maximum_kettle_volume.unit_name.should == :litres    
  end
  
  it "should return sample loss volume in litres" do
    Brewhouse.sample_loss.unit_name.should == :litres    
  end

  it "should return sparge loss volume in litres" do
    Brewhouse.sparge_loss.unit_name.should == :litres    
  end

  it "should return trub loss volume in litres" do
    Brewhouse.trub_loss.unit_name.should == :litres    
  end

  it "should return litres water absorbed per gram of hops volume in litres" do
    Brewhouse.litres_water_absorbed_per_g_of_hops.unit_name.should == :litres    
  end

  it "should return litres water absorbed per kg of grain in litres" do
    Brewhouse.litres_water_absorbed_per_kg_of_grain.unit_name.should == :litres    
  end

  it "should return water lost in false bottom in litres" do
    Brewhouse.water_lost_in_false_bottom.unit_name.should == :litres    
  end
end