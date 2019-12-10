module Pumi
  class Location
    class << self
      attr_accessor :data_store_key

      def all
        data.values
      end

      def find_by_id(id)
        data[id]
      end

      def where(params)
        data.values.select do |location|
          (params.transform_keys(&:to_s).to_a - location.attributes.to_a).empty?
        end
      end

      private

      def data
        Pumi.data_store.fetch(data_store_key, self)
      end
    end

    attr_reader :id, :attributes, :name_en, :name_km

    def initialize(code, attributes)
      @id = code
      @attributes = attributes
      @attributes["id"] = id
      @name_en = attributes.fetch("name_en")
      @name_km = attributes.fetch("name_km")
    end
  end
end
