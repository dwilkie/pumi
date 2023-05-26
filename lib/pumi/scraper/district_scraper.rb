module Pumi
  module Scraper
    class DistrictScraper
      URL = "https://en.wikipedia.org/wiki/List_of_districts,_municipalities_and_sections_in_Cambodia".freeze

      def scrape!
        District.all.each_with_object([]) do |district, result|
          url = find_url(district)
          next unless url

          result << Result.new(code: district.id, wikipedia: url)
        end
      end

      private

      def scraper
        @scraper ||= WebScraper.new(URL)
      end

      def find_url(district)
        identifier = district.id.chars.each_slice(2).map(&:join).join("-")
        list_items = scraper.page.xpath("//ol/li[text()[contains(., '#{identifier}')]]")

        return if list_items.empty?

        if list_items.size > 1
          raise WebScraper::ElementNotFoundError,
                "More than one element was found with the identifier '#{identifier}' on #{URL}"
        end

        link = list_items.first.xpath("child::a").first
        URI.join(URL, link[:href]).to_s
      end
    end
  end
end
