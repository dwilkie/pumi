module Pumi
  Location = Struct.new(
    :id, :province_id, :district_id, :commune_id, :village_id,
    :name_km, :full_name_km,
    :name_latin, :full_name_latin,
    :name_en, :full_name_en,
    :administrative_unit, keyword_init: true
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
        Pumi.data_store.load(self, key: data_store_key)
      end
    end

    attr_accessor :attributes

    def initialize(attributes)
      @attributes = attributes
      super
    end

    def province
      Province.find_by_id(province_id)
    end

    def district
      District.find_by_id(district_id)
    end

    def commune
      Commune.find_by_id(commune_id)
    end

    def village
      Village.find_by_id(village_id)
    end

    AddressType = Struct.new(:locale, :default_delimiter, keyword_init: true)
    [
      AddressType.new(locale: :km, default_delimiter: " "),
      AddressType.new(locale: :latin, default_delimiter: ", "),
      AddressType.new(locale: :en, default_delimiter: ", ")
    ].each do |address|
      define_method("address_#{address.locale}") do |delimiter: address.default_delimiter|
        [
          village&.attributes&.fetch(:"full_name_#{address.locale}"),
          commune&.attributes&.fetch(:"full_name_#{address.locale}"),
          district&.attributes&.fetch(:"full_name_#{address.locale}"),
          province&.attributes&.fetch(:"full_name_#{address.locale}")
        ].compact.join(delimiter)
      end
    end
  end
end
