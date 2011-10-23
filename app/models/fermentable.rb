class Fermentable
  attr_accessor(:name,:potential,:color,:weight,:mashable,:type)
  def initialize(params = {})
    @name = params["NAME"]
    @potential = params["POTENTIAL"].to_f
    @color = params["COLOR"].to_f
    @weight = params["AMOUNT"].to_f
    @mashable = (params["RECOMMEND_MASH"] == "TRUE")
    @type = params["TYPE"]
  end

  def grain?
    self.type == "Grain"
  end

  def gravity_points_per_pound
    ((self.potential - 1) * 1000).round
  end

  def kilograms
    @weight.round(3)
  end

  def pounds
    (@weight * 2.2046).round(2)
  end

  def total_gravity_points
    (gravity_points_per_pound * pounds).to_f
  end
end
