require "spec_helper"

module Pumi
  module DataSource
    RSpec.xdescribe Geocoder, :vcr, vcr_options: { tag: :google_api, record: :new_episodes } do
      describe "#load_data!", cassette: :geocode_cambodian_provinces do
        it "loads geodata" do
          data_source = Geocoder.new(
            geocoder: Pumi::DataSource::Geocoder::CambodianProvinces.new(regeocode: true),
            data_file: DataFile.new(:provinces)
          )

          data_source.load_data!(output_dir: "tmp")

          data = YAML.load_file("tmp/provinces.yml").fetch("provinces")
          expect(data.keys.map(&:length).uniq).to eq([2])
          expect(data.values.map { |v| v["geodata"] }.size).to eq(25)
        end
      end

      describe Geocoder::CambodianProvinces, cassette: :geocode_cambodian_provinces do
        describe "#geocode_all" do
          it "loads data from Geocoder" do
            geocoder = Geocoder::CambodianProvinces.new(regeocode: true)

            results = geocoder.geocode_all

            expect(results.size).to eq(25)
            expect(results.first.lat).to eq("13.7989147")
          end
        end
      end

      describe Geocoder::CambodianDistricts, cassette: :geocode_cambodian_districts do
        describe "#geocode_all" do
          it "loads data from Geocoder" do
            geocoder = Geocoder::CambodianDistricts.new(regeocode: true)

            results = geocoder.geocode_all

            expect(results.size).to be > 150
            expect(results.first.lat).to eq("13.4940861")
          end
        end
      end

      describe Geocoder::CambodianCommunes, cassette: :geocode_cambodian_communes do
        describe "#geocode_all" do
          it "loads data from Geocoder" do
            geocoder = Geocoder::CambodianCommunes.new(regeocode: true)

            results = geocoder.geocode_all

            expect(results.size).to be > 1000
            expect(results.first.lat).to eq("13.5104093")
          end
        end
      end
    end
  end
end
