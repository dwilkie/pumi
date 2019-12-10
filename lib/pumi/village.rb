module Pumi
  class Village < Commune
    self.data_store_key = :villages

    attr_reader :commune_id

    def initialize(id, attributes)
      super
      @commune_id = @attributes["commune_id"] = id.chars.first(6).join
    end

    def commune
      Commune.find_by_id(commune_id)
    end
  end
end
