require "spec_helper"

module Pumi
  RSpec.describe Province do
    describe ".all" do
      it "returns all provinces" do
        results = Province.all

        expect(results.size).to eq(25)
        expect(results.first).to be_a(Province)
      end
    end

    describe ".where" do
      it "returns an empty result if the filter doesn't match" do
        results = Province.where(id: "01", name_latin: "Phnom Penh")

        expect(results).to be_empty
      end

      it "filters by id" do
        results = Province.where(id: "01")

        province = results.first
        expect(results.size).to eq(1)
        expect(province.id).to eq("01")
        expect(province.name_km).to eq("បន្ទាយមានជ័យ")
        expect(province.full_name_km).to eq("ខេត្តបន្ទាយមានជ័យ")
        expect(province.name_latin).to eq("Banteay Meanchey")
        expect(province.full_name_latin).to eq("Khaet Banteay Meanchey")
        expect(province.name_en).to eq("Banteay Meanchey")
        expect(province.full_name_en).to eq("Banteay Meanchey Province")
        expect(province.name_ungegn).to eq("Bântéay Méanchoăy")
        expect(province.full_name_ungegn).to eq("Khétt Bântéay Méanchoăy")
      end

      it "filters by name_latin" do
        results = Province.where(name_latin: "Phnom Penh")

        province = results.first
        expect(results.size).to eq(1)
        expect(province.full_name_km).to eq("រាជធានីភ្នំពេញ")
        expect(province.full_name_latin).to eq("Reach Theani Phnom Penh")
        expect(province.full_name_en).to eq("Phnom Penh Capital")
      end

      it "filters by name_km" do
        results = Province.where(name_km: "កំពត")

        province = results.first
        expect(results.size).to eq(1)
        expect(province.name_latin).to eq("Kampot")
      end
    end

    describe ".find_by_id" do
      it "finds the province by id" do
        expect(Province.find_by_id("12")).not_to eq(nil)
        expect(Province.find_by_id("99")).to eq(nil)
      end
    end

    describe "#links" do
      it "returns a list of links" do
        expect(Province.find_by_id("12").links).to eq(
          wikipedia: "https://en.wikipedia.org/wiki/Phnom_Penh"
        )
      end
    end

    describe "#geodata" do
      it "returns geodata" do
        geodata = Province.find_by_id("12").geodata
        expect(geodata).to have_attributes(
          lat: "11.5730391",
          long: "104.857807",
          bounding_box: ["11.4200852", "11.7349524", "104.7204046", "105.0440261"]
        )
      end
    end

    describe "#iso3166_2" do
      it "returns the ISO3166-2 code" do
        expect(Province.find_by_id("12").iso3166_2).to eq("KH-12")
      end
    end
  end
end
