require "spec_helper"
require "pry"

module Pumi
  module DataSource
    RSpec.describe Wikipedia do
      describe "#load_data!" do
        it "loads data from Wikipedia" do
          data_loader = Wikipedia.new(
            scraper: Pumi::DataSource::Wikipedia::CambodianProvincesScraper.new,
            data_file: DataFile.new(:provinces)
          )

          data_loader.load_data!(output_dir: "tmp")

          data = YAML.load_file("tmp/provinces.yml").fetch("provinces")
          expect(data.keys.map(&:length).uniq).to eq([2])
          expect(data.values.map { |v| v["wikipedia"] }.size).to eq(25)
        end
      end

      describe Wikipedia::CambodianProvincesScraper do
        describe "#scrape!" do
          it "loads data from Wikipedia" do
            scraper = Wikipedia::CambodianProvincesScraper.new

            result = scraper.scrape!

            expect(result.size).to eq(25)
            expect(result.first.wikipedia).to eq("https://en.wikipedia.org/wiki/Banteay_Meanchey_province")
          end
        end
      end

      describe Wikipedia::CambodianDistrictsScraper do
        describe "#scrape!" do
          it "loads data from Wikipedia" do
            scraper = Wikipedia::CambodianDistrictsScraper.new

            result = scraper.scrape!

            expect(result.size).to eq(201)
            expect(result.first.wikipedia).to eq("https://en.wikipedia.org/wiki/Mongkol_Borei_District")
          end
        end
      end

      describe Wikipedia::CambodianCommunesScraper do
        describe "#scrape!" do
          it "loads data from Wikipedia" do
            scraper = Wikipedia::CambodianCommunesScraper.new

            result = scraper.scrape!

            expect(result.size).to eq(282)
            expect(result.first.wikipedia).to eq("https://en.wikipedia.org/wiki/Banteay_Neang")
          end
        end
      end
    end
  end
end
