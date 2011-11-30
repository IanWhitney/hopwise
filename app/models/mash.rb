class Mash
  attr_accessor :starting_grain_temp

  def initialize(attributes)
    @starting_grain_temp = attributes["GRAIN_TEMP"].to_f.celsius
  end
end