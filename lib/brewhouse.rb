class Brewhouse
  def self.fermenter_loss
    (1.89).litres
  end
  
  def self.hourly_evaporation_rate
    0.10
  end
  
  def self.maximum_kettle_volume
    (26.50).liters
  end
  
  def self.sample_loss
    (0.6).litres
  end
  
  def self.sparge_loss
    (0.1).litres
  end

  def self.trub_loss
    (3.0).litres
  end

  def self.litres_water_absorbed_per_kg_of_grain
    (0.91).litres
  end
  
  def self.water_lost_in_false_bottom
    (1.20).litres
  end
end