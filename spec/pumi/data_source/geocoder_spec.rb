require "spec_helper"
require "pry"

module Pumi
  module DataSource
    RSpec.describe Geocoder do
      describe "#load_data!" do
        it "loads geodata" do
          data_loader = Geocoder.new(
            geocoder: Pumi::DataSource::Geocoder::CambodianProvinces.new,
            data_file: DataFile.new(:provinces)
          )

          data_loader.load_data!(output_dir: "tmp")

          data = YAML.load_file("tmp/provinces.yml").fetch("provinces")
          expect(data.keys.map(&:length).uniq).to eq([2])
          expect(data.values.map { |v| v["geodata"] }.size).to eq(25)
        end
      end

      describe Geocoder::CambodianProvinces do
        describe "#geocode_all" do
          it "loads data from Geocoder" do
            geocoder = Geocoder::CambodianProvinces.new

            results = geocoder.geocode_all

            expect(results.size).to eq(25)
            expect(results.first.lat).to eq("13.7989147")
          end
        end
      end

      describe Geocoder::CambodianDistricts do
        describe "#geocode_all" do
          it "loads data from Geocoder" do
            geocoder = Geocoder::CambodianDistricts.new

            results = geocoder.geocode_all

            expect(results.size).to eq(25)
            expect(results.first.lat).to eq("13.7989147")
          end
        end
      end
    end
  end
end
