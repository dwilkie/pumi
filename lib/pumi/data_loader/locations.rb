module Pumi
  module DataLoader
    class Locations
      attr_reader :data_file, :scraper

      def initialize(data_file:, scraper:)
        @data_file = data_file
        @scraper = scraper
      end

      def load_data!(output_dir: "data")
        data.each do |code, attributes|
          location_data = scraped_data.find { |location| location.code == code }
          next unless location_data

          attributes["wikipedia"] = location_data.wikipedia
        end

        write_data!(output_dir)
      end

      private

      def scraped_data
        @scraped_data ||= scraper.scrape!
      end

      def data
        @data ||= data_file.read
      end

      def write_data!(data_directory)
        data_file.write(data, data_directory:)
      end
    end
  end
end
