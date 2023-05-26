require "spec_helper"

module Pumi
  module Scraper
    RSpec.describe DistrictScraper do
      describe "#scrape!" do
        it "loads data from Wikipedia" do
          scraper = DistrictScraper.new

          result = scraper.scrape!

          expect(result.size).to eq(202)
          expect(result.first.wikipedia).to eq("https://en.wikipedia.org/wiki/Mongkol_Borei_District")
        end
      end
    end
  end
end
