require 'delegate'

class Gallon < DelegateClass(Float)
  def to_oz
    self * 128
  end
  
  def to_l
    self * 3.78541178
  end
  
  def to_ml
    self.to_l * 1000
  end
end