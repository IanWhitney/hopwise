class Misc
  attr_accessor(:name, :time)
  def initialize(params = {})
    @name = params["NAME"]
    @time = params["TIME"].to_i
    @amount = params["AMOUNT"].to_f.kilograms
  end
  
  def amount(recipe)
    if self.name == "Yeast Nutrient"
      (Brewhouse.yeast_nutrient_per_liter.to_f * recipe.fermenter_volume.to_f).grams
    elsif self.name == "Whirlfloc Tablet"
      (Brewhouse.whirlfloc_per_liter.to_f * recipe.post_boil_volume.to_f).grams
    else
      @amount
    end
    # elsif self.name == "Whirlfloc Tablet"
    #   "wt"
    # else
    #   @amount
    # end    
  end
  
end
