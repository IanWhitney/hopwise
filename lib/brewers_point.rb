require 'delegate'

class BrewersPoint < DelegateClass(Float)
  def to_sg
    SpecificGravity.new(self / 1000 + 1)
  end
end