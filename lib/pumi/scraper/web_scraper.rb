require "nokogiri"
require "open-uri"

module Pumi
  module Scraper
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
  end
end
