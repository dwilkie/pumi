module Pumi
  Geodata = Struct.new(:lat, :long, :bounding_box, keyword_init: true)
end
