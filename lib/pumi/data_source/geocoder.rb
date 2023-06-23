require "geocoder"
# require "redis"
require "pry"

module Pumi
  module DataSource
    class Geocoder
      Result = Struct.new(:code, :lat, :long, :bounding_box, keyword_init: true)

      class AbstractGeocoder
        Result = Struct.new(
          :lat, :long, :bounding_box, :country_code,
          :types, :iso3166_2, :district_name_en,
          keyword_init: true
        )

        class AbstractProvider
          attr_reader :geocoder, :name

          def initialize(geocoder:, name:)
            @geocoder = geocoder
            @name = name
          end

          def search(term)
            geocoder.search(term, lookup: name).map do |result|
              build_result(result.data)
            end
          end
        end

        class Google < AbstractProvider
          private

          def build_result(data)
            province_name_en = find_address_component(
              data,
              "administrative_area_level_1"
            ).fetch("long_name")
            province = Pumi::Province.where(full_name_en: province_name_en)

            Result.new(
              lat: data.dig("geometry", "location", "lat"),
              long: data.dig("geometry", "location", "lng"),
              bounding_box: [
                data.dig("geometry", "bounds", "northeast", "lat"),
                data.dig("geometry", "bounds", "northeast", "lng"),
                data.dig("geometry", "bounds", "southwest", "lat"),
                data.dig("geometry", "bounds", "southwest", "lng")
              ],
              country_code: find_address_component(data, "country").fetch("short_name").upcase,
              district_name_en: find_address_component(
                data,
                "administrative_area_level_2"
              ).fetch("long_name"),
              types: data["types"],
              iso3166_2: province&.iso3166_2
            )
          end

          def find_address_component(data, type)
            data.fetch("address_components").find do |c|
              c.fetch("types").include?(type)
            end
          end
        end

        class Nominatim < AbstractProvider
          private

          def build_result(data)
            Result.new(
              lat: data["lat"],
              long: data["lon"],
              bounding_box: data["boundingbox"],
              types: Array(data["type"]),
              iso3166_2: data.dig("address", "ISO3166-2-lvl4"),
              country_code: data.dig("address", "country_code").upcase,
              district_name_en: data.dig("address", "county")
            )
          end
        end

        PROVIDERS = {
          nominatim: Nominatim,
          google: Google
        }.freeze

        attr_reader :providers, :options

        def initialize(geocoder: ::Geocoder, providers: PROVIDERS.keys, **options)
          @options = options

          geocoder.configure(
            google: {
              api_key: ENV["GOOGLE_API_KEY"]
            }
            # cache: Redis.new
          )

          @providers = Array(providers).map do |name|
            PROVIDERS.fetch(name).new(geocoder:, name:)
          end
        end

        def geocode_all
          locations.each_with_object([]).with_index do |(location, results), index|
            next if !options[:regeocode] && !location.geodata.nil?

            puts "Geocoding #{index + 1} of #{locations.size}"

            geocoder_result = geocode(location)

            if geocoder_result.nil?
              puts "Unable to geocode ('#{location.address_en}', '#{location.address_latin}')"
              ungeocoded_locations << location
              next
            end

            puts "Found: #{geocoder_result.inspect}, in: #{location.address_en}"
            results << build_result(code: location.id, geocoder_result:)
          end
        end

        private

        def geocode(location)
          providers.each do |provider|
            Array(build_search_term(location)).each do |search_term|
              puts "Searching for: '#{search_term}' with provider: #{provider.name}"

              all_results = provider.search(search_term)
              geocoder_result = filter(location, all_results)

              return geocoder_result unless geocoder_result.nil?
            end
          end

          nil
        end

        def build_result(code:, geocoder_result:)
          Geocoder::Result.new(
            code:,
            lat: geocoder_result.lat,
            long: geocoder_result.long,
            bounding_box: geocoder_result.bounding_box
          )
        end

        def build_search_term(location)
          [location.full_name_km, location.name_km]
        end

        def ungeocoded_locations
          @ungeocoded_locations ||= []
        end
      end

      class CambodianProvinces < AbstractGeocoder
        private

        def locations
          @locations ||= Pumi::Province.all
        end

        def build_search_term(province)
          province.iso3166_2
        end

        def filter(province, geocoder_results)
          geocoder_results.find do |r|
            r.iso3166_2 == province.iso3166_2 && r.types.include?("administrative")
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
            r.country_code == "KH" &&
              r.iso3166_2 == district.province.iso3166_2 &&
              %w[town city administrative].any? { |type| r.types.include?(type) }
          end
        end
      end

      class CambodianCommunes < AbstractGeocoder
        private

        def locations
          # @locations ||= Pumi::Commune.all
          @locations ||= Pumi::Commune.all.find_all { |c| c.geodata.nil? }.first(1)
        end

        def filter(commune, geocoder_results)
          geocoder_results.find do |r|
            r.country_code == "KH" &&
              (r.iso3166_2 == commune.province.iso3166_2 || r.district_name_en.to_s.downcase.include?(commune.district.name_en.downcase)) &&
              %w[village suburb neighbourhood].any? { |type| r.types.include?(type) }
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
