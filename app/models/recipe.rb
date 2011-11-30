class Recipe < ActiveRecord::Base
  has_attached_file :xml
  
  validates_uniqueness_of :batch_number
  validates_presence_of :xml, :name

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
    100 * ((estimated_original_gravity.to.brewers_points - estimated_final_gravity.to.brewers_points) / estimated_original_gravity.to.brewers_points)
  end

  def estimated_final_gravity
    sg = @xml["EST_FG"].to_f.specific_gravity
  end

  def estimated_original_gravity
    mashed = (pre_boil_gravity.to.brewers_points / (1 - self.total_evaporation_rate)).brewers_points
    sugars = (unmashed_gravity.to.brewers_points.to_f / post_boil_volume.to.gallons.to_f).brewers_points
    total = (mashed + sugars).to_f
    total.brewers_points.to.specific_gravity
  end

  def expected_efficiency
    @xml["EFFICIENCY"] ? (@xml["EFFICIENCY"].to_f / 100) : 0.70
  end

  def expected_mash_gravity
    (maximum_mash_gravity.to.brewers_points * expected_efficiency).to_f.brewers_points.to.specific_gravity
  end

  def fermentables
    # Doing fermentables.sort_by {|x| [x.late_addition? ? 1 : 0, x.weight]} gave me the fermentables sorted by weight in ascending, not descending order.
    unsorted_fermentables = xml_collection_to_objects("fermentable")
    a = unsorted_fermentables.reject {|x| x.late_addition?}
    b = unsorted_fermentables.reject {|x| !x.late_addition?}
    (a.sort {|x,y| y.weight <=> x.weight}) + (b.sort {|x,y| y.weight <=> x.weight})
  end

  def fermentation_temperature
    @xml["PRIMARY_TEMP"].to_i.to_fahrenheit
  end

  def fermenter_volume
    post_boil_volume.to_f - Brewhouse.trub_loss.to_f - Brewhouse.sample_loss.to_f
  end
  
  def first_wort_hops
    (all_hops.reject {|h| !h.first_wort?})
  end

  def grains
    fermentables.reject {|f| !f.grain?}
  end

  def grain_weight
    (grains.sum {|g| g.weight.to_f})
  end
  
  def ibu
    @xml["IBU"]
  end

  def ibu_method
    @xml["IBU_METHOD"]
  end
  
  def mash
    @xml["MASHS"]["MASH"]
  end

  def mash_details_included?
    @xml["MASHS"] && @xml["MASHS"]["MASH"]
  end

  def mash_temp
    if mash_details_included?
      begin
        @xml["MASHS"]["MASH"]["MASH_STEPS"].first[1].first["STEP_TEMP"].to_f.celsius
      rescue
        @xml["MASHS"]["MASH"]["MASH_STEPS"].first[1]["STEP_TEMP"].to_f.celsius
      end
    end
  end

  def mash_thickness
    2.6
  end

  def mash_volume
    (grain_weight * mash_thickness).litres
  end

  def maximum_mash_gravity
    (((grains.sum {|g| g.total_gravity_points}) / pre_boil_volume.to.gallons.to_f)).brewers_points.to.specific_gravity
  end

  def notes
    @xml["NOTES"] ? (@xml["NOTES"]).html_safe : nil
  end

  def unmashed_gravity
    ((fermentables.reject {|f| f.grain?}).sum {|x| x.total_gravity_points}).brewers_points.to.specific_gravity
  end

  def post_boil_volume
    (pre_boil_volume.to_f - (pre_boil_volume.to_f * total_evaporation_rate)).liters
  end

  def pre_boil_volume
    @xml["BOIL_SIZE"].to_f.liters
  end

  def pre_boil_gravity
    expected_mash_gravity
  end

  def packaging_volume
    (self.fermenter_volume.to_f - Brewhouse.fermenter_loss.to_f).liters
  end

  def runnings
    (mash_volume.to_f - water_absorbed_by_grain - Brewhouse.water_lost_in_false_bottom.to_f).liters
  end

  def sparge_water
    (pre_boil_volume.to_f - runnings.to_f).liters
  end

  def strike_temp(goal_temp, original_temp)
    ((0.2/(2.5/2)) * (goal_temp - original_temp) + goal_temp).celsius
  end

  def style
    @xml["STYLE"]["NAME"]
  end

  def total_evaporation_rate
    ((boil_length.to_f / 60.0) * Brewhouse.hourly_evaporation_rate)
  end

  def water_absorbed_by_grain
    grain_weight * Brewhouse.litres_water_absorbed_per_kg_of_grain.to_f
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
