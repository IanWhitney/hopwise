class Misc
  attr_accessor(:name, :time)
  def initialize(params = {})
    @name = params["NAME"]
    @time = params["TIME"].to_i
  end
end
