require "spec_helper"

module Pumi
  RSpec.describe Commune do
    describe ".all" do
      it "returns all communes" do
        results = Commune.all

        expect(results.size).to eq(1652)
        expect(results.first).to be_a(Commune)
      end
    end

    describe ".where" do
      it "filters by id" do
        results = Commune.where(id: "010201")

        commune = results.first
        expect(results.size).to eq(1)
        expect(commune.id).to eq("010201")
        expect(commune.name_km).to eq("បន្ទាយនាង")
        expect(commune.full_name_km).to eq("ឃុំបន្ទាយនាង")
        expect(commune.name_latin).to eq("Banteay Neang")
        expect(commune.full_name_latin).to eq("Khum Banteay Neang")
        expect(commune.name_en).to eq("Banteay Neang")
        expect(commune.full_name_en).to eq("Banteay Neang Commune")
        expect(commune.name_ungegn).to eq("Bântéay Néang")
        expect(commune.full_name_ungegn).to eq("Khŭm Bântéay Néang")
        expect(commune.district.name_en).to eq("Mongkol Borei")
        expect(commune.province.name_en).to eq("Banteay Meanchey")
      end

      it "filters by district_id" do
        results = Commune.where(district_id: "0102")

        expect(results.size).to eq(13)
        expect(results.map(&:district_id).uniq).to eq(["0102"])
      end

      it "filters by province_id" do
        results = Commune.where(province_id: "01")

        expect(results.size).to eq(67)
        expect(results.map(&:province_id).uniq).to eq(["01"])
      end

      it "filters by name_latin" do
        results = Commune.where(name_latin: "Tonle Basak")

        commune = results.first
        expect(results.size).to eq(1)
        expect(commune.full_name_km).to eq("សង្កាត់ទន្លេបាសាក់")
        expect(commune.full_name_latin).to eq("Sangkat Tonle Basak")
        expect(commune.full_name_en).to eq("Tonle Basak Quarter")
      end

      it "filters by name_km" do
        results = Commune.where(name_km: "អូរបីជាន់")

        district = results.first
        expect(results.size).to eq(1)
        expect(district.id).to eq("010509")
        expect(district.name_en).to eq("Ou Beichoan")
      end
    end

    describe ".find_by_id" do
      it "finds the commune by id" do
        expect(Commune.find_by_id("010509")).not_to eq(nil)
        expect(Commune.find_by_id("010599")).to eq(nil)
      end
    end
  end
end
