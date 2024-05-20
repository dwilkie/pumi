module Pumi
  Location = Struct.new(
    :id, :province_id, :district_id, :commune_id, :village_id,
    :province, :district, :commune,
    :name_km, :full_name_km,
    :name_latin, :full_name_latin,
    :name_en, :full_name_en,
    :name_ungegn, :full_name_ungegn,
    :address_km, :address_latin, :address_en,
    :administrative_unit,
    :links,
    :geodata,
    :iso3166_2,
    keyword_init: true
  ) do
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
          (params.transform_keys(&:to_s).to_a - location.attributes.transform_keys(&:to_s).to_a).empty?
        end
      end

      private

      def data
        Pumi.data_store.load(self)
      end
    end

    attr_accessor :attributes

    def initialize(attributes)
      @attributes = attributes
      super
    end
  end
end
