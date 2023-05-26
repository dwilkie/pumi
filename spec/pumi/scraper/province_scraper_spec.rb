require "spec_helper"

module Pumi
  module Scraper
    RSpec.describe ProvinceScraper do
      describe "#scrape!" do
        it "loads data from Wikipedia" do
          scraper = ProvinceScraper.new

          result = scraper.scrape!

          expect(result.size).to eq(25)
          expect(result.first.wikipedia).to eq("https://en.wikipedia.org/wiki/Banteay_Meanchey_province")
        end
      end
    end
  end
end
