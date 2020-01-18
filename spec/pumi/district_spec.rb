require "spec_helper"

module Pumi
  RSpec.describe District do
    describe ".all" do
      it "returns all districts" do
        results = District.all

        expect(results.size).to eq(203)
        expect(results.first).to be_a(District)
      end
    end

    describe ".where" do
      it "filters by id" do
        results = District.where(id: "0102")

        district = results.first
        expect(results.size).to eq(1)
        expect(district.id).to eq("0102")
        expect(district.name_km).to eq("មង្គលបូរី")
        expect(district.full_name_km).to eq("ស្រុកមង្គលបូរី")
        expect(district.name_latin).to eq("Mongkol Borei")
        expect(district.full_name_latin).to eq("Srok Mongkol Borei")
        expect(district.name_en).to eq("Mongkol Borei")
        expect(district.full_name_en).to eq("Mongkol Borei District")
        expect(district.province.name_en).to eq("Banteay Meanchey")
      end

      it "filters by province_id" do
        results = District.where(province_id: "01")

        expect(results.size).to eq(9)
        expect(results.map(&:province_id).uniq).to eq(["01"])
      end

      it "filters by name_latin" do
        results = District.where(name_latin: "Chamkar Mon")

        district = results.first
        expect(results.size).to eq(1)
        expect(district.full_name_km).to eq("ខណ្ឌចំការមន")
        expect(district.full_name_latin).to eq("Khan Chamkar Mon")
        expect(district.full_name_en).to eq("Chamkar Mon Section")
      end

      it "filters by name_km" do
        results = District.where(name_km: "ល្វាឯម")

        district = results.first
        expect(results.size).to eq(1)
        expect(district.name_en).to eq("Lvea Aem")
      end
    end

    describe ".find_by_id" do
      it "finds the district by id" do
        expect(District.find_by_id("0102")).not_to eq(nil)
        expect(District.find_by_id("0199")).to eq(nil)
      end
    end
  end
end
