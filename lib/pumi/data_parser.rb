require "pathname"
require "csv"
require "yaml"

# https://en.wikipedia.org/wiki/Administrative_divisions_of_Cambodia
# https://en.wikipedia.org/wiki/Romanization_of_Khmer
# https://en.wikipedia.org/wiki/United_Nations_Group_of_Experts_on_Geographical_Names

module Pumi
  class DataParser
    CSV_HEADERS = %w[type code name_km name_latin reference note1 note2].freeze

    AdministrativeUnit = Struct.new(:en, :km, :latin, :code_length, :group, keyword_init: true)
    ADMINISTRATIVE_UNITS = {
      "ស្រុក" => AdministrativeUnit.new(en: "District", km: "ស្រុក", latin: "Srok", code_length: 4, group: "districts"),
      "ខណ្ឌ" => AdministrativeUnit.new(en: "Section", km: "ខណ្ឌ", latin: "Khan", code_length: 4, group: "districts"),
      "ក្រុង" => AdministrativeUnit.new(en: "Municipality", km: "ក្រុង", latin: "Krong", code_length: 4, group: "districts"),
      "ឃុំ" => AdministrativeUnit.new(en: "Commune", km: "ឃុំ", latin: "Khum", code_length: 6, group: "communes"),
      "សង្កាត់" => AdministrativeUnit.new(en: "Quarter", km: "សង្កាត់", latin: "Sangkat", code_length: 6, group: "communes"),
      "ភូមិ" => AdministrativeUnit.new(en: "Village", km: "ភូមិ", latin: "Phum", code_length: 8, group: "villages")
    }.freeze

    def load_data!(source_dir: "tmp")
      data = {}

      source_files(source_dir).each do |file|
        CSV.read(file, headers: CSV_HEADERS).each do |row|
          code = row.fetch("code")
          next if code.to_s.gsub(/\D/, "").empty?

          code = code.rjust(code.length + 1, "0") if code.length.odd?
          administrative_unit = ADMINISTRATIVE_UNITS.fetch(row.fetch("type"))

          next if administrative_unit.code_length != code.length

          data[administrative_unit.group] ||= {}
          data[administrative_unit.group][code] = {
            "name" => {
              "km" => row.fetch("name_km"),
              "latin" => row.fetch("name_latin")
            },
            "administrative_unit" => {
              "km" => administrative_unit.km,
              "latin" => administrative_unit.latin,
              "en" => administrative_unit.en
            }
          }
        end
      end

      data
    end

    def write_data!(data, destination_dir: "data")
      return if data.empty?

      data_groups.each do |group|
        File.write(
          "#{destination_dir}/#{group}.yml",
          { group => data.fetch(group).sort.to_h }.to_yaml
        )
      end
    end

    private

    def source_files(source_dir)
      Pathname.glob("#{source_dir}/*.csv").select(&:file?)
    end

    def data_groups
      ADMINISTRATIVE_UNITS.values.map(&:group).uniq
    end
  end
end
