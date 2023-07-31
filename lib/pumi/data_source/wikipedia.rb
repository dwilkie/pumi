require "nokogiri"
require "open-uri"

module Pumi
  module DataSource
    class Wikipedia
      attr_reader :data_file, :scraper

      def initialize(data_file:, scraper:)
        @data_file = data_file
        @scraper = scraper
      end

      def load_data!(output_dir: "data")
        data.each do |code, attributes|
          location_data = scraped_data.find { |location| location.code == code }
          next unless location_data

          attributes["links"] ||= {}
          attributes["links"]["wikipedia"] = location_data.wikipedia
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

      ScraperResult = Struct.new(:code, :wikipedia, keyword_init: true)

      class WebScraper
        class ElementNotFoundError < StandardError; end

        attr_reader :url

        def initialize(url)
          @url = url
        end

        def page
          @page ||= Nokogiri::HTML(URI.parse(url).open)
        end
      end

      class CambodianProvincesScraper
        URL = "https://en.wikipedia.org/wiki/Provinces_of_Cambodia".freeze

        def scrape!
          Province.all.each_with_object([]) do |province, result|
            result << ScraperResult.new(code: province.id, wikipedia: find_url(province))
          end
        end

        private

        def scraper
          @scraper ||= WebScraper.new(URL)
        end

        def find_url(province)
          td = province_table_rows.at_xpath("child::td[contains(., '#{province.name_km}')]")
          if td.nil?
            raise WebScraper::ElementNotFoundError,
                  "No cell containing '#{province.name_km}' was found in a table on #{URL}"
          end

          link = td.at_xpath("preceding-sibling::td/a[contains(@href, '/wiki/')]")
          URI.join(URL, link[:href]).to_s
        end

        def province_table_rows
          @province_table_rows ||= begin
            sample_province = Province.all.first

            sample_row = scraper.page.at_xpath("//table/tbody/tr[td//text()[contains(., '#{sample_province.name_km}')]]")
            if sample_row.at_xpath("//a[text()[contains(., '#{sample_province.name_en}')]]").nil?
              raise WebScraper::ElementNotFoundError,
                    "No link containing '#{sample_province.name_en}' was found in a table on #{URL}"
            end

            sample_row.parent.xpath("child::tr")
          end
        end
      end

      class CambodianDistrictsScraper
        URL = "https://en.wikipedia.org/wiki/List_of_districts,_municipalities_and_sections_in_Cambodia".freeze

        def scrape!
          District.all.each_with_object([]) do |district, result|
            url = find_url(district)
            next unless url

            result << ScraperResult.new(code: district.id, wikipedia: url)
          end
        end

        private

        def scraper
          @scraper ||= WebScraper.new(URL)
        end

        def find_url(district)
          geocode = scraper.page.at_xpath("//td[text()[contains(., '#{district.id}')]]")

          return if geocode.nil?

          link = geocode.at_xpath("preceding-sibling::td/a[contains(@href, '/wiki/')]")

          return if link.nil?

          URI.join(URL, link[:href]).to_s
        end
      end

      class CambodianCommunesScraper
        URL = "https://en.wikipedia.org/wiki/List_of_communes_in_Cambodia".freeze

        def scrape!
          Commune.all.each_with_object([]) do |commune, result|
            url = find_url(commune)
            next if url.nil?

            result << ScraperResult.new(code: commune.id, wikipedia: url)
          end
        end

        private

        def find_url(commune)
          geocode = scraper.page.at_xpath("//td[text()[contains(., '#{commune.id}')]]")

          return if geocode.nil?

          link = geocode.at_xpath("preceding-sibling::td/a[contains(@href, '/wiki/')]")

          return if link.nil?

          URI.join(URL, link[:href]).to_s
        end

        def scraper
          @scraper ||= WebScraper.new(URL)
        end
      end
    end
  end
end
