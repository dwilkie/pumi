require "pathname"
require "csv"
require "yaml"

# https://en.wikipedia.org/wiki/Administrative_divisions_of_Cambodia
# https://en.wikipedia.org/wiki/Romanization_of_Khmer
# https://en.wikipedia.org/wiki/United_Nations_Group_of_Experts_on_Geographical_Names

module Pumi
  module DataSource
    class NCDD
      CSV_HEADERS = %w[type code name_km name_latin reference note1 note2].freeze

      AdministrativeUnit = Struct.new(:en, :km, :latin, :code_length, :group, :type, keyword_init: true)
      Row = Struct.new(:code, :name_km, :name_latin, :type, keyword_init: true) do
        def administrative_unit
          ADMINISTRATIVE_UNITS.fetch(type)
        end
      end

      ADMINISTRATIVE_UNITS = {
        "ស្រុក" => AdministrativeUnit.new(en: "District", km: "ស្រុក", latin: "Srok", code_length: 4, group: "districts"),
        "ខណ្ឌ" => AdministrativeUnit.new(en: "Section", km: "ខណ្ឌ", latin: "Khan", code_length: 4, group: "districts"),
        "ក្រុង" => AdministrativeUnit.new(en: "Municipality", km: "ក្រុង", latin: "Krong", code_length: 4, group: "districts"),
        "ឃុំ" => AdministrativeUnit.new(en: "Commune", km: "ឃុំ", latin: "Khum", code_length: 6, group: "communes"),
        "សង្កាត់" => AdministrativeUnit.new(en: "Quarter", km: "សង្កាត់", latin: "Sangkat", code_length: 6, group: "communes"),
        "ភូមិ" => AdministrativeUnit.new(en: "Village", km: "ភូមិ", latin: "Phum", code_length: 8, group: "villages")
      }.freeze

      def load_data!(source_dir: "tmp", output_dir: "data")
        source_files(source_dir).each do |file|
          parse_source_file(file)
        end

        write_data!(output_dir)
      end

      private

      def parse_source_file(file)
        CSV.read(file, headers: CSV_HEADERS).each do |csv_row|
          row = build_row(csv_row)

          next unless row.code
          next if row.administrative_unit.code_length != row.code.length

          write_location(row)
        end
      end

      def data
        @data ||= {}
      end

      def build_row(row)
        Row.new(
          code: parse_location_code(row),
          name_km: row.fetch("name_km"),
          name_latin: row.fetch("name_latin"),
          type: row.fetch("type")
        )
      end

      def parse_location_code(row)
        code = row.fetch("code")
        return if code.to_s.gsub(/\D/, "").empty?

        code = code.rjust(code.length + 1, "0") if code.length.odd?
        code
      end

      def write_location(row)
        data[row.administrative_unit.group] ||= {}
        data[row.administrative_unit.group][row.code] = {
          "name" => {
            "km" => row.name_km,
            "latin" => row.name_latin
          },
          "administrative_unit" => {
            "km" => row.administrative_unit.km,
            "latin" => row.administrative_unit.latin,
            "en" => row.administrative_unit.en
          }
        }
      end

      def source_files(source_dir)
        Pathname.glob("#{source_dir}/*.csv").select(&:file?)
      end

      def write_data!(output_dir)
        return if data.empty?

        ADMINISTRATIVE_UNITS.values.map(&:group).uniq do |data_group|
          DataFile.new(data_group).write(data.fetch(data_group), data_directory: output_dir)
        end
      end
    end
  end
end