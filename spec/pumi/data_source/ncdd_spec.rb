require "spec_helper"
require "pumi/data_source/ncdd"

module Pumi
  module DataSource
    RSpec.describe NCDD do
      describe "#load_data!" do
        it "loads data from source" do
          data_source = NCDD.new

          data_source.load_data!(
            source_dir: "spec/fixtures/files/source_data/ncdd",
            output_dir: "tmp"
          )

          expect(YAML.load_file("tmp/districts.yml").fetch("districts").keys.map(&:length).uniq).to eq([4])
          expect(YAML.load_file("tmp/communes.yml").fetch("communes").keys.map(&:length).uniq).to eq([6])
          expect(YAML.load_file("tmp/villages.yml").fetch("villages").keys.map(&:length).uniq).to eq([8])
        end
      end
    end
  end
end
