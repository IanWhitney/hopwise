class Recipe < ActiveRecord::Base
  has_attached_file :xml
  
  default_scope order('batch_number')

  def after_initialize
    if !self.new_record?
      @xml = Hash.from_xml(File.open(self.xml.path))["RECIPES"]["RECIPE"]
    end
  end

  def additions
    if @xml["MISCS"].respond_to?(:keys) 
      xml_collection_to_objects("misc").sort! {|a,b| b.time <=> a.time }
    end
  end

  def all_hops
    xml_collection_to_objects("hop")
  end

  def aroma_hops
    all_hops.reject {|h| !h.aroma?}
  end

  def boil_hops
    all_hops.reject {|h| !h.boil?}
  end

  def boil_length
    @xml["BOIL_TIME"].to_i
  end

  def color
    @xml["EST_COLOR"]
  end
  
  def dry_hops
    (all_hops.reject {|h| !h.dry?})
  end

  def estimated_apparent_attenuation
    100 * ((estimated_original_gravity - estimated_final_gravity) / estimated_original_gravity)
  end

  def estimated_final_gravity
    BrewersPoint.new((@xml["EST_FG"].to_f - 1) * 1000)
  end

  def estimated_original_gravity
    BrewersPoint.new(pre_boil_gravity / (1 - self.total_evaporation_rate))
  end

  def expected_efficiency
    @xml["EFFICIENCY"] ? (@xml["EFFICIENCY"].to_f / 100) : 0.70
  end

  def expected_mash_gravity
    BrewersPoint.new(maximum_mash_gravity * expected_efficiency)
  end

  def evaporation_rate
    0.15
  end

  def fermentables
    xml_collection_to_objects("fermentable")
  end

  def fermentation_temperature
    @xml["PRIMARY_TEMP"].to_i.to_fahrenheit
  end

  def fermenter_loss
    Gallon.new(0.50)
  end

  def fermenter_volume
    Gallon.new(self.post_boil_volume - self.trub_loss)
  end
  
  def first_wort_hops
    (all_hops.reject {|h| !h.first_wort?})
  end

  def grains
    fermentables.reject {|f| !f.grain?}
  end

  def grain_weight
    (grains.sum {|g| g.pounds})
  end
  
  def ibu
    @xml["IBU"]
  end

  def ibu_method
    @xml["IBU_METHOD"]
  end
  
  def mash_details_included?
    @xml["MASHS"] && @xml["MASHS"]["MASH"]
  end

  def mash_temp
    if mash_details_included?
      begin
        @xml["MASHS"]["MASH"]["MASH_STEPS"].first[1].first["STEP_TEMP"].to_f.to_fahrenheit
      rescue
        @xml["MASHS"]["MASH"]["MASH_STEPS"].first[1]["STEP_TEMP"].to_f.to_fahrenheit
      end
    end
  end

  def mash_thickness
    2.5
  end

  def mash_volume
    Gallon.new((grain_weight * 16 * mash_thickness))
  end

  def maximum_mash_gravity
    BrewersPoint.new(((grains.sum {|g| g.total_gravity_points}) / pre_boil_volume))
  end

  def notes
    @xml["NOTES"] ? (@xml["NOTES"]).html_safe : nil
  end

  def post_boil_volume
    Gallon.new(pre_boil_volume - (pre_boil_volume * total_evaporation_rate))
  end

  def pre_boil_volume
    Gallon.new(@xml["BOIL_SIZE"].to_f * 0.264172052)
  end

  def pre_boil_gravity
    expected_mash_gravity
  end

  def packaging_volume
    Gallon.new(self.fermenter_volume - self.fermenter_loss)
  end

  def runnings
    (mash_volume - water_absorbed_by_grain - water_lost_in_false_bottom)
  end

  def sparge_water
    (pre_boil_volume.to_oz) - runnings
  end

  def strike_temp(goal_temp, original_temp)
    (0.2/(mash_thickness/2)) * (goal_temp - original_temp) + goal_temp
  end

  def style
    @xml["STYLE"]["NAME"]
  end

  def total_evaporation_rate
    ((boil_length.to_f / 60.0) * evaporation_rate)
  end

  def trub_loss
    Gallon.new(0.75)
  end

  def water_absorbed_per_pound_of_grain
    Gallon.new(13.0/128).to_oz
  end

  def water_absorbed_by_grain
    grain_weight * water_absorbed_per_pound_of_grain
  end

  def water_lost_in_false_bottom
    44
  end

  def yeasts
    xml_collection_to_objects("yeast")
  end
private

  def flattened_array_or_hash(key)
    if @xml[key].respond_to?(:values)
      if @xml[key].values.first.respond_to?(:each_value)
        [@xml[key].values.first]
      else
        @xml[key].values.first
      end
    else
      # Added to fix a problem with importing a Northern Brewer xml file that had 4 duplicate entries in "HOPS" that were stored in an array, not a hash.
      @xml[key].first.values.first
    end
  end
    
  def xml_collection_to_objects(collection)
    object_collection = []
    flattened_array_or_hash(collection.pluralize.upcase).each do |f|
      object_collection << Object::const_get(collection.camelcase).new(f)
    end
    object_collection
  end
end
