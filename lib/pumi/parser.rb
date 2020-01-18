require "yaml"
require "pathname"

module Pumi
  class Parser
    DATA_DIRECTORY = Pathname.new(File.expand_path("..", File.dirname(__dir__))).join("data")

    attr_reader :type, :key

    def initialize(type, key:)
      @type = type
      @key = key
    end

    def load
      data = YAML.load_file(DATA_DIRECTORY.join("#{key}.yml")).fetch(key.to_s)
      data.each_with_object({}) do |(id, attributes), result|
        name = attributes.fetch("name")
        name_km = name.fetch("km")
        name_latin = name.fetch("latin")
        administrative_unit = build_administrative_unit(
          attributes.fetch("administrative_unit")
        )

        result[id] = type.new(
          id: id,
          administrative_unit: administrative_unit,
          province_id: administrative_unit_code(id, 2),
          district_id: administrative_unit_code(id, 4),
          commune_id: administrative_unit_code(id, 6),
          village_id: administrative_unit_code(id, 8),
          name_km: name_km,
          name_latin: name_latin,
          name_en: name_latin,
          full_name_km: [
            administrative_unit_name(name_km, administrative_unit.name_km),
            name_km
          ].compact.join,
          full_name_latin: [
            administrative_unit_name(name_latin, administrative_unit.name_latin),
            name_latin
          ].compact.join(" "),
          full_name_en: [name_latin, administrative_unit.name_en].join(" ")
        )
      end
    end

    private

    def build_administrative_unit(attributes)
      AdministrativeUnit.new(
        name_km: attributes.fetch("km"),
        name_latin: attributes.fetch("latin"),
        name_en: attributes.fetch("en")
      )
    end

    def administrative_unit_name(name, administrative_unit_name)
      administrative_unit_name unless name.start_with?(administrative_unit_name)
    end

    def administrative_unit_code(id, length)
      id.chars.first(length).join if id.length >= length
    end
  end
end
