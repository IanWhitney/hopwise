class Addition
  attr_accessor(:name, :time)
  def initialize(params = {})
    @name = params["NAME"]
    @time = params["TIME"]
  end
end
