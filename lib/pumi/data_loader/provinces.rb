module Pumi
  module DataLoader
    class Provinces
      class ProvinceScraper
        require "nokogiri"
        require "open-uri"

        URL = "https://en.wikipedia.org/wiki/Provinces_of_Cambodia".freeze
        DataPoint = Struct.new(:code, :wikipedia, keyword_init: true)

        def scrape!
          ::Pumi::Province.all.each_with_object([]) do |province, result|
            result << DataPoint.new(code: province.id, wikipedia: find_reference_url(province))
          end
        end

        private

        def page
          @page ||= Nokogiri::HTML(URI.parse(URL).open)
        end

        def province_rows
          @province_rows ||= begin
            sample_province = Province.all.first

            sample_row = page.xpath("//table/tbody/tr[td//text()[contains(., '#{sample_province.name_km}')]]").first
            if sample_row.xpath("//a[text()[contains(., '#{sample_province.name_en}')]]").empty?
              raise ElementNotFoundError,
                    "No link containing '#{sample_province.name_en}' was found in a table on #{URL}"
            end

            sample_row.parent.xpath("child::tr")
          end
        end

        def find_reference_url(province)
          td = province_rows.xpath("child::td[contains(., '#{province.name_km}')]").first
          if td.nil?
            raise ElementNotFoundError,
                  "No cell containing '#{province.name_km}' was found in a table on #{URL}"
          end

          link = td.xpath("preceding-sibling::td/a").first
          URI.join(URL, link[:href]).to_s
        end
      end

      def load_data!(output_dir: "data")
        data.each do |code, attributes|
          province = scraped_data.find { |p| p.code == code }
          attributes["wikipedia"] = province.wikipedia
        end

        write_data!(output_dir)
      end

      private

      def scraped_data
        @scraped_data ||= scraper.scrape!
      end

      def data
        @data ||= DataFile.new(:provinces).read
      end

      def write_data!(data_directory)
        DataFile.new(:provinces, data_directory:).write(data)
      end

      def scraper
        @scraper ||= ProvinceScraper.new
      end
    end
  end
end
