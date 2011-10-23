class Yeast
  attr_accessor(:name)
  def initialize(params = {})
    @name = params["NAME"]
  end
end