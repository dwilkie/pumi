require "geocoder"

module Pumi
  module DataSource
    class Geocoder
      attr_reader :data_file

      def initialize(data_file:)
        @data_file = data_file
      end

      def load_data!(output_dir: "data")
        data.each do |code, _attributes|
          province = Pumi::Province.find_by_id(code)

          results = ::Geocoder.search(province.name_en)

          raise "Too many results" if results.size > 1
          raise "No results" if results.empty?

          result = results.first

          p result
        end
      end

      private

      def data
        @data ||= data_file.read
      end
    end
  end
end
