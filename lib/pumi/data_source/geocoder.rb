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

        def geocode_all
          locations.each_with_object([]).with_index do |(location, results), index|
            next if !options[:regeocode] && !location.geodata.nil?

            search_term = build_search_term(location)
            puts "Geocoding #{index + 1} of #{locations.size}. Search term: '#{search_term}'"

            geocoder_results = geocoder.search(search_term)
            geocoder_result = filter(location, geocoder_results)

            if geocoder_result.nil?
              puts "Unable to geocode '#{search_term}' ('#{location.address_en}', '#{location.address_latin}'). Found: #{geocoder_results}"
              ungeocoded_locations << location
              next
            end

            puts "Found: #{geocoder_result.inspect}, in: #{location.address_en}"
            results << build_result(code: location.id, geocoder_result:)
          end
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

        def build_search_term(location)
          location.full_name_km
        end

        def ungeocoded_locations
          @ungeocoded_locations ||= []
        end

        def iso3166_2(province)
          "KH-#{province.id.to_i}"
        end
      end

      class CambodianProvinces < AbstractGeocoder
        private

        def locations
          @locations ||= Pumi::Province.all
        end

        def build_search_term(province)
          iso3166_2(province)
        end

        def filter(province, geocoder_results)
          geocoder_results.find do |r|
            r.data["address"]["ISO3166-2-lvl4"] == iso3166_2(province) && r.data["type"] == "administrative"
          end
        end
      end

      class CambodianDistricts < AbstractGeocoder
        private

        def locations
          @locations ||= Pumi::District.all
        end

        def filter(district, geocoder_results)
          geocoder_results.find do |r|
            r.data["address"]["country_code"] == "kh" &&
              r.data["address"]["ISO3166-2-lvl4"] == iso3166_2(district.province) &&
              %w[town city administrative].include?(r.data["type"])
          end
        end
      end

      class CambodianCommunes < AbstractGeocoder
        private

        def locations
          @locations ||= Pumi::Commune.all
        end

        def filter(commune, geocoder_results)
          geocoder_results.find do |r|
            r.data["address"]["country_code"] == "kh" &&
              (r.data["address"]["ISO3166-2-lvl4"] == iso3166_2(commune.province) || r.data["address"]["county"].to_s.include?(commune.district.name_en)) &&
              %w[village suburb neighbourhood].include?(r.data["type"])
          end
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
