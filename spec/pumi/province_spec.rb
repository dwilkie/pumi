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
  end
end
