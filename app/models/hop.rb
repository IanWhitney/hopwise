class Hop
  attr_accessor(:name, :weight, :alpha, :form)

  def initialize(params = {})
    @name = params["NAME"]
    @weight = params["AMOUNT"].to_f.kilograms.to.grams
    @alpha = params["ALPHA"]
    @form = params["FORM"]
    @time = params["TIME"]
    @use = params["USE"]
  end

  def aroma?
    @use == "Aroma"
  end

  def boil?
    @use == "Boil"
  end
  
  def dry?
    @use == "Dry Hop"
  end

  def first_wort?
    @use == "First Wort"
  end
  
  def time
    self.dry? ? (@time.to_i / 60 / 24) : @time
  end 
end