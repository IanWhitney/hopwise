class Brewhouse
  def self.fermenter_loss
    (1.89).litres
  end
  
  def self.hourly_evaporation_rate
    0.18
  end
  
  def self.maximum_kettle_volume
    (54).litres
  end
  
  def self.sample_loss
    (0.0).litres
  end
  
  def self.sparge_loss
    (0.1).litres
  end

  def self.trub_loss
    (2.0).litres
  end

  def self.litres_water_absorbed_per_g_of_hops
    (0.015).litres
  end

  def self.litres_water_absorbed_per_kg_of_grain
    (0.91).litres
  end

  def self.percent_gravity_extracted_in_first_runnings
    (0.63)
  end

  def self.water_lost_in_false_bottom
    (1.20).litres
  end
  
  def self.whirlfloc_per_liter
    (0.027).grams
  end
  
  def self.yeast_nutrient_per_liter
    (0.115).grams
  end
end