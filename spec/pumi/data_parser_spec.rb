require "spec_helper"

module Pumi
  RSpec.describe DataParser do
    describe "#load_data!" do
      it "loads data from source" do
        data_parser = DataParser.new

        data = data_parser.load_data!(source_dir: "spec/fixtures/files/source_data")

        expect(data.fetch("districts").keys.map(&:length).uniq).to eq([4])
        expect(data.fetch("communes").keys.map(&:length).uniq).to eq([6])
        expect(data.fetch("villages").keys.map(&:length).uniq).to eq([8])
      end
    end

    describe "#write_data!" do
      it "writes the data as yaml" do
        data_parser = DataParser.new

        data = data_parser.load_data!(source_dir: "spec/fixtures/files/source_data")
        data_parser.write_data!(data, destination_dir: "tmp")

        expect(File.exist?("tmp/districts.yml")).to eq(true)
        expect(File.exist?("tmp/communes.yml")).to eq(true)
        expect(File.exist?("tmp/villages.yml")).to eq(true)
      end
    end
  end
end
