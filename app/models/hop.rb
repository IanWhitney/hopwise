class Hop
  attr_reader(:name, :weight, :alpha, :form)

  def initialize(params = {})
    @name = params["NAME"]
    @weight = params["AMOUNT"].to_f.kilograms.to.grams
    @alpha = params["ALPHA"]
    @form = params["FORM"]
    @time = params["TIME"]
    @use = params["USE"]
  end

  def aroma?
    @use.downcase == "aroma"
  end

  def boil?
    @use.downcase == "boil"
  end
  
  def dry?
    @use.downcase == "dry hop"
  end

  def first_wort?
    @use.downcase == "first wort"
  end
  
  def leaf?
    @form.downcase == "leaf"
  end
  
  def time
    self.dry? ? (@time.to_i / 60 / 24) : @time.to_i
  end 
end