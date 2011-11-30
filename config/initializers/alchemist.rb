# [from new measure to SG, from SG to new measure]
Alchemist.register(:density, [:brewers_points], [
  Proc.new{|bp| (bp / 1000.0) + 1}, 
  Proc.new{|sg| (sg - 1) * 1000}
])
Alchemist.register(:density, [:terril_brix], [
  Proc.new{|tb| ((tb/1.04)/(258.6-(((tb/1.04)/258.2)*227.1))+1) }, 
  Proc.new{ |sg| (-676.67 + (1286.4*sg) - (800.47*sg*sg) + (190.74*sg*sg*sg)) * 1.04 }
])