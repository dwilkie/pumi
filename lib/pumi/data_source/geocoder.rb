require "geocoder"

module Pumi
  module DataSource
    class Geocoder
      Result = Struct.new(:code, :lat, :long, :bounding_box, keyword_init: true)

      class AbstractGeocoder
        attr_reader :geocoder, :options

        def initialize(geocoder: ::Geocoder, **options)
          @geocoder = geocoder
          @options = options
        end

        private

        def build_result(code:, geocoder_result:)
          Geocoder::Result.new(
            code:,
            lat: geocoder_result.data["lat"],
            long: geocoder_result.data["lon"],
            bounding_box: geocoder_result.data["boundingbox"]
          )
        end
      end

      class CambodianProvinces < AbstractGeocoder
        def geocode_all
          Pumi::Province.all.each_with_object([]) do |province, results|
            next if !options[:regeocode] && !province.geodata.nil?

            iso_code = "KH-#{province.id.to_i}"
            geocoder_results = geocoder.search(iso_code)
            geocoder_result = geocoder_results.find do |r|
              r.data["address"]["ISO3166-2-lvl4"] == iso_code && r.data["type"] == "administrative"
            end

            raise "No results from #{geocoder_results}" if geocoder_result.nil?

            results << build_result(code: province.id, geocoder_result:)
          end
        end
      end

      class CambodianDistricts < AbstractGeocoder
        def geocode_all
          Pumi::District.all.each_with_object([]) do |district, results|
            next if !options[:regeocode] && !district.geodata.nil?

            district_name = district.full_name_km
            geocoder_results = geocoder.search(district_name)
            geocoder_result = geocoder_results.find do |r|
              r.data["address"]["country_code"] == "kh" &&
                %w[town city administrative].include?(r.data["type"])
            end

            if geocoder_result.nil?
              ungeocoded_districts << district
              next
            end

            results << build_result(code: district.id, geocoder_result:)
          end
        end

        private

        def ungeocoded_districts
          @ungeocoded_districts ||= []
        end
      end

      attr_reader :data_file, :geocoder

      def initialize(data_file:, geocoder:)
        @data_file = data_file
        @geocoder = geocoder
      end

      def load_data!(output_dir: "data")
        data.each do |code, attributes|
          geocoded_result = geocoded_results.find { |r| r.code == code }

          next if geocoded_result.nil?

          attributes["geodata"] ||= {}
          attributes["geodata"]["lat"] = geocoded_result.lat
          attributes["geodata"]["long"] = geocoded_result.long
          attributes["geodata"]["bounding_box"] = geocoded_result.bounding_box
        end

        write_data!(output_dir)
      end

      private

      def data
        @data ||= data_file.read
      end

      def write_data!(data_directory)
        data_file.write(data, data_directory:)
      end

      def geocoded_results
        @geocoded_results ||= geocoder.geocode_all
      end
    end
  end
end
