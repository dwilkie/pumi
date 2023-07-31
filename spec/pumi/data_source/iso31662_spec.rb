require "spec_helper"

module Pumi
  module DataSource
    RSpec.describe ISO31662 do
      describe "#load_data!" do
        it "loads ISO3166-2 codes" do
          data_source = ISO31662.new

          data_source.load_data!(output_dir: "tmp")

          data = YAML.load_file("tmp/provinces.yml").fetch("provinces")
          expect(data.values.map { |v| v["iso3166_2"] }.size).to eq(25)
        end
      end
    end
  end
end
