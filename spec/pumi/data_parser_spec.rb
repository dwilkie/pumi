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
      data_parser = DataParser.new

      data = data_parser.load_data!(source_dir: "spec/fixtures/files/source_data")
      data_parser.write_data!(data, destination_dir: "tmp")
    end
  end
end
