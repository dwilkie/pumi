require "spec_helper"

module Pumi
  RSpec.describe DataSet do
    describe "#provinces" do
      it "returns a hash of provinces" do
        expect(DataSet.new.provinces.dig("03", "name_en")).to eq("Kampong Cham")
      end

      it "returns a hash of districts" do
        expect(DataSet.new.districts.dig("0102", "name_en")).to eq("Mongkol Borei")
      end

      it "returns a hash of communes" do
        expect(DataSet.new.communes.dig("010201", "name_en")).to eq("Banteay Neang")
      end

      it "returns a hash of villages" do
        expect(DataSet.new.villages.dig("01020101", "name_en")).to eq("Ou Thum")
      end
    end
  end
end
