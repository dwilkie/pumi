require "spec_helper"

module Pumi
  RSpec.describe Parser do
    describe "#load" do
      it "returns a hash of provinces" do
        expect(Parser.new.load(:provinces).dig("03", "name_en")).to eq("Kampong Cham")
      end

      it "returns a hash of districts" do
        expect(Parser.new.load(:districts).dig("0102", "name_en")).to eq("Mongkol Borei")
      end

      it "returns a hash of communes" do
        expect(Parser.new.load(:communes).dig("010201", "name_en")).to eq("Banteay Neang")
      end

      it "returns a hash of villages" do
        expect(Parser.new.load(:villages).dig("01020101", "name_en")).to eq("Ou Thum")
      end
    end
  end
end
