class Fermentable
  attr_accessor(:name,:potential,:color,:weight,:mashable,:type,:late_addition)
  def initialize(params = {})
    @name = params["NAME"]
    @potential = params["POTENTIAL"].to_f
    @color = params["COLOR"].to_f
    @weight = params["AMOUNT"].to_f.kilograms
    @mashable = (params["RECOMMEND_MASH"] == "TRUE")
    @type = params["TYPE"]
    @late_addition = (params["ADD_AFTER_BOIL"] == "TRUE")
  end

  def grain?
    self.type == "Grain"
  end

  def gravity_points_per_pound
    ((self.potential - 1) * 1000).round
  end

  def total_gravity_points
    (gravity_points_per_pound * self.weight.to.pounds.value).to_f
  end
  
  def late_addition?
    @late_addition
  end
end
