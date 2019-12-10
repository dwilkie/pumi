module Pumi
  class District < Location
    self.data_store_key = :districts

    attr_reader :province_id

    def initialize(id, attributes)
      super
      @province_id = @attributes["province_id"] = id.chars.first(2).join
    end

    def province
      Province.find_by_id(province_id)
    end
  end
end
