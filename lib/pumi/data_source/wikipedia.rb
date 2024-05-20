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

          if location_data.wikipedia
            attributes["links"] ||= {}
            attributes["links"]["wikipedia"] = location_data.wikipedia
          end

          attributes["name"]["ungegn"] = location_data.name_ungegn if location_data.name_ungegn
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

      ScraperResult = Struct.new(:code, :wikipedia, :name_ungegn, keyword_init: true)

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
            result << ScraperResult.new(
              code: province.id,
              wikipedia: find_url(province),
              name_ungegn: find_ungegn(province)
            )
          end
        end

        private

        def scraper
          @scraper ||= WebScraper.new(URL)
        end

        def find_url(province)
          td = find_khmer_name_td(province)
          link = td.at_xpath("preceding-sibling::td/a[contains(@href, '/wiki/')]")
          URI.join(URL, link[:href]).to_s
        end

        def find_ungegn(province)
          td = find_khmer_name_td(province)
          td.at_xpath("following-sibling::td/span[contains(@title, 'Khmer-language romanization')]")&.text
        end

        def find_khmer_name_td(province)
          td = province_table_rows.at_xpath("child::td[contains(., '#{province.name_km}')]")

          if td.nil?
            raise WebScraper::ElementNotFoundError,
                  "No cell containing '#{province.name_km}' was found in a table on #{URL}"
          end

          td
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
            result << ScraperResult.new(
              code: district.id,
              wikipedia: find_url(district),
              name_ungegn: find_ungegn(district)
            )
          end
        end

        private

        def scraper
          @scraper ||= WebScraper.new(URL)
        end

        def find_url(district)
          geocode_td = find_geocode_td(district)

          return if geocode_td.nil?

          link = geocode_td.at_xpath("preceding-sibling::td/a[contains(@href, '/wiki/')]")

          return if link.nil?

          URI.join(URL, link[:href]).to_s
        end

        def find_ungegn(district)
          geocode_td = find_geocode_td(district)

          return if geocode_td.nil?

          geocode_td.at_xpath("preceding-sibling::td/span[contains(@title, 'Khmer-language romanization')]")&.text
        end

        def find_geocode_td(district)
          scraper.page.at_xpath("//td[text()[contains(., '#{district.id}')]]")
        end
      end

      class CambodianCommunesScraper
        URL = "https://en.wikipedia.org/wiki/List_of_communes_in_Cambodia".freeze

        def scrape!
          Commune.all.each_with_object([]) do |commune, result|
            result << ScraperResult.new(
              code: commune.id,
              wikipedia: find_url(commune),
              name_ungegn: find_ungegn(commune)
            )
          end
        end

        private

        def find_url(commune)
          geocode_td = find_geocode_td(commune)

          return if geocode_td.nil?

          link = geocode_td.at_xpath("preceding-sibling::td/a[contains(@href, '/wiki/')]")

          return if link.nil?

          URI.join(URL, link[:href]).to_s
        end

        def find_ungegn(commune)
          geocode_td = find_geocode_td(commune)

          return if geocode_td.nil?

          geocode_td.at_xpath("preceding-sibling::td/span[contains(@title, 'Khmer-language romanization')]")&.text
        end

        def find_geocode_td(commune)
          scraper.page.at_xpath("//td[text()[contains(., '#{commune.id}')]]")
        end

        def scraper
          @scraper ||= WebScraper.new(URL)
        end
      end
    end
  end
end
