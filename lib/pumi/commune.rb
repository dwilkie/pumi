module Pumi
  class Commune < District
    self.data_store_key = :communes

    attr_reader :district_id

    def initialize(id, attributes)
      super
      @district_id = @attributes["district_id"] = id.chars.first(4).join
    end

    def district
      District.find_by_id(district_id)
    end
  end
end
