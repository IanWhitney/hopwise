class Hop
  attr_accessor(:name, :weight, :alpha, :form)

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

  def initialize(params = {})
    @name = params["NAME"]
    @weight = params["AMOUNT"].to_f
    @alpha = params["ALPHA"]
    @form = params["FORM"]
    @time = params["TIME"]
    @use = params["USE"]
  end
  
  def grams
    (@weight.round(4) * 1000)
  end  
  
  def time
    self.dry? ? (@time.to_i / 60 / 24) : @time
  end 
end