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
      MISSING_DATA = {
        "1715" => { type: "ក្រុង" }
      }.freeze

      Misspelling = Struct.new(:incorrect_text, :correct_text, keyword_init: true)

      MISSPELLINGS = [
        Misspelling.new(incorrect_text: "Siem Reab", correct_text: "Siem Reap"),
        Misspelling.new(incorrect_text: "Aoral", correct_text: "Aural"),
        Misspelling.new(incorrect_text: "Angk  Romeas", correct_text: "Angk Romeas"),
        Misspelling.new(incorrect_text: "Prea​ek Chrey", correct_text: "Preaek Chrey"),
        Misspelling.new(incorrect_text: "Saensokh", correct_text: "Sen Sok"),
        Misspelling.new(incorrect_text: "Kaeb", correct_text: "Kep"),
        Misspelling.new(incorrect_text: "Taing Kouk", correct_text: "Tang Kouk"),
        Misspelling.new(incorrect_text: "Mongkol Borei", correct_text: "Mongkol Borey"),
        Misspelling.new(incorrect_text: "wat Kor", correct_text: "Wat Kor"),
        Misspelling.new(incorrect_text: "OMal", correct_text: "Ou Mal")
      ].freeze

      AdministrativeUnit = Struct.new(:en, :km, :latin, :ungegn, :code_length, :group, :type, keyword_init: true)
      Row = Struct.new(:code, :name_km, :name_latin, :type, keyword_init: true) do
        def administrative_unit
          ADMINISTRATIVE_UNITS.fetch(type)
        end
      end

      ADMINISTRATIVE_UNITS = {
        "ស្រុក" => AdministrativeUnit.new(
          en: "District",
          km: "ស្រុក",
          latin: "Srok",
          ungegn: "Srŏk",
          code_length: 4,
          group: "districts"
        ),
        "ខណ្ឌ" => AdministrativeUnit.new(
          en: "Section",
          km: "ខណ្ឌ",
          latin: "Khan",
          ungegn: "Khând",
          code_length: 4,
          group: "districts"
        ),
        "ក្រុង" => AdministrativeUnit.new(
          en: "Municipality",
          km: "ក្រុង",
          latin: "Krong",
          ungegn: "Krŏng",
          code_length: 4,
          group: "districts"
        ),
        "ឃុំ" => AdministrativeUnit.new(
          en: "Commune",
          km: "ឃុំ",
          latin: "Khum",
          ungegn: "Khŭm",
          code_length: 6,
          group: "communes"
        ),
        "សង្កាត់" => AdministrativeUnit.new(
          en: "Quarter",
          km: "សង្កាត់",
          latin: "Sangkat",
          ungegn: "Sângkéat",
          code_length: 6,
          group: "communes"
        ),
        "ភូមិ" => AdministrativeUnit.new(
          en: "Village",
          km: "ភូមិ",
          latin: "Phum",
          ungegn: "Phum",
          code_length: 8,
          group: "villages"
        )
      }.freeze

      attr_accessor :existing_data

      def initialize(data_files: default_data_files)
        @existing_data = data_files.each_with_object({}) do |data_file, result|
          result[data_file.type] = data_file.read
        end
      end

      def load_data!(source_dir: "tmp", output_dir: "data")
        source_files(source_dir).each do |file|
          parse_source_file(file)
        end

        write_data!(output_dir)
      end

      private

      def data
        @data ||= {}
      end

      def parse_source_file(file)
        CSV.read(file, headers: CSV_HEADERS).each do |csv_row|
          row = build_row(csv_row)

          next unless row.code
          next if row.administrative_unit.code_length != row.code.length

          add_data(row)
        end
      end

      def build_row(row)
        code = parse_location_code(row)

        name_latin = row.fetch("name_latin")
        name_latin = MISSPELLINGS.find { |m| m.incorrect_text == name_latin }&.correct_text || name_latin

        Row.new(
          code:,
          name_km: row.fetch("name_km"),
          name_latin:,
          type: row.fetch("type") || MISSING_DATA.dig(code, :type)
        )
      end

      def parse_location_code(row)
        code = row.fetch("code")
        return if code.to_s.gsub(/\D/, "").empty?

        code = code.rjust(code.length + 1, "0") if code.length.odd?
        code
      end

      def add_data(row)
        data[row.administrative_unit.group] ||= {}
        data[row.administrative_unit.group][row.code] = existing_data.dig(row.administrative_unit.group, row.code) || {}
        data[row.administrative_unit.group][row.code]["name"] = existing_data.dig(row.administrative_unit.group, row.code, "name") || {}
        data[row.administrative_unit.group][row.code]["name"].merge!(
          "km" => row.name_km,
          "latin" => row.name_latin
        )
        data[row.administrative_unit.group][row.code].merge!(
          "administrative_unit" => {
            "km" => row.administrative_unit.km,
            "latin" => row.administrative_unit.latin,
            "en" => row.administrative_unit.en,
            "ungegn" => row.administrative_unit.ungegn
          }
        )
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

      def default_data_files
        [
          DataFile.new(:districts),
          DataFile.new(:communes),
          DataFile.new(:villages)
        ]
      end
    end
  end
end
