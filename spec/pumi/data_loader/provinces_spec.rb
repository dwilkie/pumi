require "spec_helper"
require "pry"

module Pumi
  module DataLoader
    RSpec.describe Provinces do
      describe "#load_data!" do
        it "loads data from Wikipedia" do
          data_loader = Provinces.new

          data_loader.load_data!(output_dir: "tmp")

          data = YAML.load_file("tmp/provinces.yml").fetch("provinces")
          expect(data.keys.map(&:length).uniq).to eq([2])
          expect(data.values.map { |v| v["wiki"] }.size).to eq(25)
        end
      end
    end
  end
end
