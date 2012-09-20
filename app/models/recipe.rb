class Recipe < ActiveRecord::Base
  has_attached_file :xml
  validates_attachment_presence :xml
  
  validates_uniqueness_of :batch_number
  validates_presence_of :name

  default_scope order('batch_number')

  def abv
    beerxml["EST_ABV"]
  end

  def additions
    if beerxml["MISCS"].respond_to?(:keys) 
      xml_collection_to_objects("misc").sort! {|a,b| b.time <=> a.time }
    end
  end

  def all_hops
    xml_collection_to_objects("hop")
  end

  def aroma_hops
    all_hops.reject {|h| !h.aroma?}
  end

  def batch_size
    beerxml["BATCH_SIZE"].to_f.litres
  end
  
  def boil_hops
    all_hops.reject {|h| !h.boil?}
  end

  def boil_length
    beerxml["BOIL_TIME"].to_f
  end

  def color
    beerxml["EST_COLOR"]
  end
  
  def dry_hops
    (all_hops.reject {|h| !h.dry?})
  end

  def estimated_apparent_attenuation
    100 * ((estimated_original_gravity.to.brewers_points - estimated_final_gravity.to.brewers_points) / estimated_original_gravity.to.brewers_points)
  end

  def estimated_final_gravity
    beerxml["EST_FG"].to_f.specific_gravity
  end
  
  def estimated_original_gravity
    #beerxml["EST_OG"].to_f.specific_gravity
    self.post_boil_original_gravity
  end

  def post_boil_original_gravity
    mashed = (pre_boil_gravity.to.brewers_points / (1 - self.total_evaporation_rate)).brewers_points
    sugars = (unmashed_gravity.to.brewers_points.to_f / post_boil_volume.to.gallons.to_f).brewers_points
    total = (mashed + sugars).to_f
    total.brewers_points.to.specific_gravity
  end

  def expected_efficiency
    beerxml["EFFICIENCY"] ? (beerxml["EFFICIENCY"].to_f / 100) : 0.70
  end

  def expected_first_runnings_gravity
    expected_total_points_in_first_runnings = Brewhouse.percent_gravity_extracted_in_first_runnings * (self.pre_boil_gravity.to.brewers_points.to_f * self.pre_boil_volume.to.gallons.to_f)
    (expected_total_points_in_first_runnings / self.expected_first_runnings_volume.to.gallons.to_f).brewers_points.to.specific_gravity
  end

  def expected_first_runnings_volume
    (mash_volume.to_f - water_absorbed_by_grain.to_f - Brewhouse.water_lost_in_false_bottom.to_f).litres
  end

  def expected_second_runnings_gravity
    expected_total_points_in_second_runnings = (1.0 - Brewhouse.percent_gravity_extracted_in_first_runnings) * (self.pre_boil_gravity.to.brewers_points.to_f * self.pre_boil_volume.to.gallons.to_f)
    (expected_total_points_in_second_runnings / (self.expected_second_runnings_volume.to.gallons.to_f)).brewers_points.to.specific_gravity
  end

  def expected_second_runnings_volume
    (self.sparge_water - Brewhouse.sparge_loss).litres
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
    beerxml["PRIMARY_TEMP"].to_i.to_fahrenheit
  end

  def fermenter_volume
    (self.wort_to_fermenter.to_f + self.make_up_water.to_f).litres
  end
  
  def first_wort_hops
    (all_hops.reject {|h| !h.first_wort?})
  end

  def grains
    fermentables.reject {|f| !f.grain?}
  end

  def grain_weight
    (grains.sum {|g| g.weight.to_f}).kilograms
  end
  
  def ibu
    beerxml["IBU"]
  end

  def ibu_method
    beerxml["IBU_METHOD"]
  end
  
  def make_up_water
    x = (self.batch_size - self.post_boil_volume).to_f
    if x > 0.5
      total_wort_needed = self.wort_to_fermenter.to_f / (estimated_original_gravity.to.brewers_points / self.post_boil_original_gravity.to.brewers_points)
      (total_wort_needed - self.wort_to_fermenter.to_f).litres
    else
      0.litres
    end
  end
  
  def mash
    beerxml["MASHS"]["MASH"]
  end

  def mash_details_included?
    beerxml["MASHS"] && beerxml["MASHS"]["MASH"]
  end

  def mash_temp
    if mash_details_included?
      begin
        beerxml["MASHS"]["MASH"]["MASH_STEPS"].first[1].first["STEP_TEMP"].to_f.celsius
      rescue
        beerxml["MASHS"]["MASH"]["MASH_STEPS"].first[1]["STEP_TEMP"].to_f.celsius
      end
    end
  end

  def mash_thickness
    2.6
  end

  def mash_volume
    calculated_mash_volume = (grain_weight.to_f * mash_thickness.to_f).litres
    if calculated_mash_volume > Brewhouse.maximum_kettle_volume
      Brewhouse.maximum_kettle_volume
    else
      calculated_mash_volume
    end
  end

  def maximum_extractable_points
    (grains.sum {|g| g.total_gravity_points})
  end

  def maximum_mash_gravity
    ((maximum_extractable_points / pre_boil_volume.to.gallons.to_f)).brewers_points.to.specific_gravity
  end

  def notes
    beerxml["NOTES"] ? (beerxml["NOTES"]).html_safe : nil
  end

  def partial_boil?
    beerxml["BATCH_SIZE"].to_f.litres > self.pre_boil_volume
  end

  def unmashed_gravity
    ((fermentables.reject {|f| f.grain?}).sum {|x| x.total_gravity_points}).brewers_points.to.specific_gravity
  end

  def post_boil_volume
    (pre_boil_volume.to_f - (pre_boil_volume.to_f * total_evaporation_rate)).litres
  end

  def pre_boil_volume
    beerxml["BOIL_SIZE"].to_f.litres
  end

  def pre_boil_gravity
    expected_mash_gravity
  end

  def packaging_volume
    (self.fermenter_volume.to_f - Brewhouse.fermenter_loss.to_f).litres
  end

  def sparge_water
    (pre_boil_volume.to_f - expected_first_runnings_volume.to_f).litres + Brewhouse.sparge_loss
  end

  def strike_temp(goal_temp, current_temp, infusion_water_volume, grain_weight, current_water_volume = 0.0)
    x = (infusion_water_volume.to_f * goal_temp.to_f - (0.4 * grain_weight.to_f + current_water_volume.to_f) * (current_temp.to_f - goal_temp.to_f)) / infusion_water_volume.to_f
    x.celsius
  end
  
  def style
    beerxml["STYLE"]["NAME"] rescue ''
  end

  def expected_hourly_evaporation_rate
    # self.hours_of_boil * Brewhouse.hourly_evaporation_rate
    if self.partial_boil?
      self.hours_of_boil * Brewhouse.hourly_evaporation_rate
    else
      ((self.pre_boil_volume - beerxml["BATCH_SIZE"].to_f.litres) / self.pre_boil_volume) / hours_of_boil
    end
  end

  def hours_of_boil
    (self.boil_length / 60.0)
  end

  def total_evaporation_rate
    (hours_of_boil * self.expected_hourly_evaporation_rate)
  end

  def water_absorbed_by_grain
    grain_weight * Brewhouse.litres_water_absorbed_per_kg_of_grain.to_f
  end

  def water_absorbed_by_hops
    loss = 0.0
    self.boil_hops.each do |h|
      loss += (Brewhouse.litres_water_absorbed_per_g_of_hops.to_f * h.weight.to_f) if h.leaf?
    end
    loss.litres
  end

  def wort_to_fermenter
    (post_boil_volume.to_f - Brewhouse.trub_loss.to_f - Brewhouse.sample_loss.to_f - self.water_absorbed_by_hops.to_f).litres
  end

  def yeasts
    xml_collection_to_objects("yeast")
  end
private

  def beerxml
    @beerxml ||= Hash.from_xml(File.open(self.xml.path))["RECIPES"]["RECIPE"]
  end

  def flattened_array_or_hash(key)
    if beerxml[key].respond_to?(:values)
      if beerxml[key].values.first.respond_to?(:each_value)
        [beerxml[key].values.first]
      else
        beerxml[key].values.first
      end
    else
      # Added to fix a problem with importing a Northern Brewer xml file that had 4 duplicate entries in "HOPS" that were stored in an array, not a hash.
      beerxml[key].first.values.first
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
