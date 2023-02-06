require "spec_helper"

module Pumi
  RSpec.describe Village do
    describe "#address" do
      it "returns the address" do
        village = Village.where(name_km: "ខ្ទុម្ពរាយលិច").first
        expect(village.address_km).to eq(
          "ភូមិខ្ទុម្ពរាយលិច ឃុំបត់ត្រង់ ស្រុកមង្គលបូរី ខេត្តបន្ទាយមានជ័យ"
        )
        expect(village.address_latin).to eq(
          "Phum Khtum Reay Lech, Khum Bat Trang, Srok Mongkol Borei, Khaet Banteay Meanchey"
        )
        expect(village.address_en).to eq(
          "Khtum Reay Lech Village, Bat Trang Commune, Mongkol Borei District, Banteay Meanchey Province"
        )
      end
    end

    describe ".all" do
      it "returns all villages" do
        results = Village.all

        expect(results.size).to eq(14_442)
        expect(results.first).to be_a(Village)
      end
    end

    describe ".where" do
      it "filters by id" do
        results = Village.where(id: "01020201")

        village = results.first
        expect(results.size).to eq(1)
        expect(village.id).to eq("01020201")
        expect(village.name_km).to eq("ខ្ទុម្ពរាយលិច")
        expect(village.full_name_km).to eq("ភូមិខ្ទុម្ពរាយលិច")
        expect(village.name_latin).to eq("Khtum Reay Lech")
        expect(village.full_name_latin).to eq("Phum Khtum Reay Lech")
        expect(village.name_en).to eq("Khtum Reay Lech")
        expect(village.full_name_en).to eq("Khtum Reay Lech Village")
        expect(village.commune.name_en).to eq("Bat Trang")
        expect(village.district.name_en).to eq("Mongkol Borei")
        expect(village.province.name_en).to eq("Banteay Meanchey")
      end

      it "filters by commune_id" do
        results = Village.where(commune_id: "010202")

        expect(results.size).to eq(11)
        expect(results.map(&:commune_id).uniq).to eq(["010202"])
      end

      it "filters by district_id" do
        results = Village.where(district_id: "0102")

        expect(results.size).to eq(159)
        expect(results.map(&:district_id).uniq).to eq(["0102"])
      end

      it "filters by province_id" do
        results = Village.where(province_id: "01")

        expect(results.size).to eq(656)
        expect(results.map(&:province_id).uniq).to eq(["01"])
      end

      it "filters by name_latin" do
        results = Village.where(name_latin: "Phum 1", commune_id: "120101")

        village = results.first
        expect(results.size).to eq(1)
        expect(village.full_name_km).to eq("ភូមិ ១")
        expect(village.full_name_latin).to eq("Phum 1")
        expect(village.full_name_en).to eq("Phum 1 Village")
      end

      it "filters by name_km" do
        results = Village.where(name_km: "ខ្ទុម្ពរាយលិច")

        district = results.first
        expect(results.size).to eq(1)
        expect(district.id).to eq("01020201")
        expect(district.name_en).to eq("Khtum Reay Lech")
      end
    end

    describe ".find_by_id" do
      it "finds the commune by id" do
        expect(Village.find_by_id("01020201")).not_to eq(nil)
        expect(Village.find_by_id("01020299")).to eq(nil)
      end
    end
  end
end
