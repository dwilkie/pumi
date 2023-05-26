module Pumi
  module Scraper
    class ProvinceScraper
      URL = "https://en.wikipedia.org/wiki/Provinces_of_Cambodia".freeze

      def scrape!
        Province.all.each_with_object([]) do |province, result|
          result << Result.new(code: province.id, wikipedia: find_url(province))
        end
      end

      private

      def scraper
        @scraper ||= WebScraper.new(URL)
      end

      def find_url(province)
        td = province_table_rows.xpath("child::td[contains(., '#{province.name_km}')]").first
        if td.nil?
          raise WebScraper::ElementNotFoundError,
                "No cell containing '#{province.name_km}' was found in a table on #{URL}"
        end

        link = td.xpath("preceding-sibling::td/a").first
        URI.join(URL, link[:href]).to_s
      end

      def province_table_rows
        @province_table_rows ||= begin
          sample_province = Province.all.first

          sample_row = scraper.page.xpath("//table/tbody/tr[td//text()[contains(., '#{sample_province.name_km}')]]").first
          if sample_row.xpath("//a[text()[contains(., '#{sample_province.name_en}')]]").empty?
            raise WebScraper::ElementNotFoundError,
                  "No link containing '#{sample_province.name_en}' was found in a table on #{URL}"
          end

          sample_row.parent.xpath("child::tr")
        end
      end
    end
  end
end
