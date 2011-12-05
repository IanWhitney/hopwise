class Brewhouse
  def self.fermenter_loss
    (1.89).litres
  end
  
  def self.hourly_evaporation_rate
    0.15
  end
  
  def self.sample_loss
    (0.6).litres
  end
  
  def self.sparge_loss
    (0.5).litres
  end

  def self.trub_loss
    2.84.litres
  end

  def self.litres_water_absorbed_per_kg_of_grain
    (0.85).litres
  end
  
  def self.water_lost_in_false_bottom
    (1.30).litres
  end
end