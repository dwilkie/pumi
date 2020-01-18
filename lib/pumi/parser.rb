require "yaml"
require "pathname"

module Pumi
  class Parser
    DATA_DIRECTORY = Pathname.new(File.expand_path("..", File.dirname(__dir__))).join("data")

    AdministrativeDivision = Struct.new(:type, :name, :data_key, :id_length, :parent_divisions, keyword_init: true)
    PROVINCE = AdministrativeDivision.new(
      type: Province,
      name: :province,
      data_key: :provinces,
      id_length: 2
    )
    DISTRICT = AdministrativeDivision.new(
      type: District,
      name: :district,
      data_key: :districts,
      id_length: 4,
      parent_divisions: [PROVINCE]
    )
    COMMUNE = AdministrativeDivision.new(
      type: Commune,
      name: :commune,
      data_key: :communes,
      id_length: 6,
      parent_divisions: [DISTRICT, PROVINCE]
    )
    VILLAGE = AdministrativeDivision.new(
      type: Village,
      name: :village,
      data_key: :villages,
      id_length: 8,
      parent_divisions: [COMMUNE, DISTRICT, PROVINCE]
    )

    ADMINISTRATIVE_DIVISIONS = {
      Province => PROVINCE,
      District => DISTRICT,
      Commune => COMMUNE,
      Village => VILLAGE
    }.freeze

    AddressType = Struct.new(:locale, :default_delimiter, keyword_init: true)
    ADDRESS_TYPES = [
      AddressType.new(locale: :km, default_delimiter: " "),
      AddressType.new(locale: :latin, default_delimiter: ", "),
      AddressType.new(locale: :en, default_delimiter: ", ")
    ].freeze

    attr_reader :type, :administrative_division

    def initialize(type)
      @type = type
      @administrative_division = ADMINISTRATIVE_DIVISIONS.fetch(type)
    end

    def load
      data = YAML.load_file(
        DATA_DIRECTORY.join("#{administrative_division.data_key}.yml")
      ).fetch(administrative_division.data_key.to_s)

      data.each_with_object({}) do |(id, attributes), result|
        location_data = build_location_data(id, attributes)
        add_parent_divisions(location_data)
        add_addresses(location_data)

        result[id] = type.new(location_data)
      end
    end

    private

    def build_location_data(id, attributes)
      name = attributes.fetch("name")
      name_km = name.fetch("km")
      name_latin = name.fetch("latin")
      administrative_unit = build_administrative_unit(
        attributes.fetch("administrative_unit")
      )

      {
        id: id,
        administrative_unit: administrative_unit,
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
      }
    end

    def add_parent_divisions(attributes)
      Array(administrative_division.parent_divisions).each do |parent|
        parent_id = attributes.fetch(:id).chars.first(parent.id_length).join
        attributes[:"#{parent.name}_id"] = parent_id
        attributes[parent.name] = parent.type.find_by_id(parent_id)
      end
    end

    def add_addresses(attributes)
      ADDRESS_TYPES.each do |address_type|
        address_part_key = :"full_name_#{address_type.locale}"
        division_address = attributes.fetch(address_part_key)
        parent_addresses = Array(administrative_division.parent_divisions).map do |parent|
          attributes.fetch(parent.name).attributes.fetch(address_part_key)
        end

        attributes[:"address_#{address_type.locale}"] = [
          division_address,
          parent_addresses
        ].reject(&:empty?).compact.join(address_type.default_delimiter)
      end
    end

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
  end
end
