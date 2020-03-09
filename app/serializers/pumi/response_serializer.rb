module Pumi
  class ResponseSerializer
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def as_json(*)
      data.map do |location|
        location.attributes.except(:province, :district, :commune, :village)
      end
    end
  end
end
