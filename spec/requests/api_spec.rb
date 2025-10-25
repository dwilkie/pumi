require "rails_helper"

RSpec.describe "API" do
  describe "GET /pumi/provinces" do
    it "returns all provinces" do
      get(Pumi::Engine.routes.url_helpers.provinces_path)

      results = JSON.parse(response.body)
      expect(results.size).to eq(25)
      expect(results.dig(0, "name_latin")).to eq("Banteay Meanchey")
    end
  end

  describe "GET /pumi/districts" do
    it "returns all districts filtered by province" do
      get(
        Pumi::Engine.routes.url_helpers.districts_path,
        params: { province_id: "01" }
      )

      results = JSON.parse(response.body)
      expect(results.size).to eq(9)
      expect(results.dig(0, "name_latin")).to eq("Mongkol Borey")
    end
  end

  describe "GET /pumi/communes" do
    it "returns all communes filtered by district" do
      get(
        Pumi::Engine.routes.url_helpers.communes_path,
        params: { district_id: "0102" }
      )

      results = JSON.parse(response.body)
      expect(results.size).to eq(13)
      expect(results.dig(0, "name_latin")).to eq("Banteay Neang")
    end
  end

  describe "GET /pumi/villages" do
    it "returns all villages filtered by commune" do
      get(
        Pumi::Engine.routes.url_helpers.villages_path,
        params: { commune_id: "010202" }
      )

      results = JSON.parse(response.body)
      expect(results.size).to eq(11)
      expect(results.dig(0, "name_latin")).to eq("Khtum Reay Lech")
    end
  end
end
