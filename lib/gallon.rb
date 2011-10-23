require 'delegate'

class Gallon < DelegateClass(Float)
  def to_oz
    self * 128
  end
end