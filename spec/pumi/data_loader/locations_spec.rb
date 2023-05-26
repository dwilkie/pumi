require "spec_helper"

module Pumi
  module DataLoader
    RSpec.describe Locations do
      describe "#load_data!" do
        it "loads data from Wikipedia" do
          data_loader = Locations.new(
            scraper: Pumi::Scraper::ProvinceScraper.new,
            data_file: DataFile.new(:provinces)
          )

          data_loader.load_data!(output_dir: "tmp")

          data = YAML.load_file("tmp/provinces.yml").fetch("provinces")
          expect(data.keys.map(&:length).uniq).to eq([2])
          expect(data.values.map { |v| v["wikipedia"] }.size).to eq(25)
        end
      end
    end
  end
end
