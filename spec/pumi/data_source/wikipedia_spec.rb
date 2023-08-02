require "spec_helper"
require "pumi/data_source/wikipedia"

module Pumi
  module DataSource
    RSpec.describe Wikipedia, :vcr do
      describe "#load_data!" do
        it "loads data from Wikipedia", cassette: :wikipedia_provinces_in_cambodia_article do
          data_source = Wikipedia.new(
            scraper: Pumi::DataSource::Wikipedia::CambodianProvincesScraper.new,
            data_file: DataFile.new(:provinces)
          )

          data_source.load_data!(output_dir: "tmp")

          data = YAML.load_file("tmp/provinces.yml").fetch("provinces")
          expect(data.keys.map(&:length).uniq).to eq([2])
          expect(data.values.map { |v| v["wikipedia"] }.size).to eq(25)
        end
      end

      xdescribe Wikipedia::CambodianProvincesScraper do
        describe "#scrape!", cassette: :wikipedia_provinces_in_cambodia_article do
          it "loads data from Wikipedia" do
            scraper = Wikipedia::CambodianProvincesScraper.new

            result = scraper.scrape!

            expect(result.size).to eq(25)
            expect(result.first.wikipedia).to eq("https://en.wikipedia.org/wiki/Banteay_Meanchey_province")
          end
        end
      end

      xdescribe Wikipedia::CambodianDistrictsScraper do
        describe "#scrape!", cassette: :wikipedia_districts_in_cambodia_article do
          it "loads data from Wikipedia" do
            scraper = Wikipedia::CambodianDistrictsScraper.new

            result = scraper.scrape!

            expect(result.size).to eq(201)
            expect(result.first.wikipedia).to eq("https://en.wikipedia.org/wiki/Mongkol_Borei_District")
          end
        end
      end

      xdescribe Wikipedia::CambodianCommunesScraper do
        describe "#scrape!", cassette: :wikipedia_communes_in_cambodia_article do
          it "loads data from Wikipedia" do
            scraper = Wikipedia::CambodianCommunesScraper.new

            result = scraper.scrape!

            expect(result.size).to eq(281)
            expect(result.first.wikipedia).to eq("https://en.wikipedia.org/wiki/Banteay_Neang")
          end
        end
      end
    end
  end
end
