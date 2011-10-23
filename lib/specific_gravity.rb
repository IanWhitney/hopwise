require 'delegate'

class SpecificGravity < DelegateClass(Float)
  def to_brix
    261.33*(1-1/self)
  end
end