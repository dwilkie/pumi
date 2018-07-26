require 'rails_helper'

describe "API" do
  let(:search_params) { {} }
  let(:json) { JSON.parse(response.body) }

  def do_api_request
    get(api_endpoint, params: search_params)
  end

  describe "'/pumi/provinces'" do
    let(:api_endpoint) { Pumi::Engine.routes.url_helpers.provinces_path }
    include_examples "api request"
  end

  describe "'/pumi/districts'" do
    let(:api_endpoint) { Pumi::Engine.routes.url_helpers.districts_path }
    include_examples "api request"

    context "filtering by province" do
      let(:province_id) { "12" }
      let(:search_params) { { :province_id => province_id } }

      before do
        do_api_request
      end

      it { expect(json.map { |district| Pumi::District.new(district.delete("id"), district).province_id }.uniq).to eq([province_id]) }
    end
  end

  describe "'/pumi/communes'" do
    let(:api_endpoint) { Pumi::Engine.routes.url_helpers.communes_path }
    include_examples "api request"

    context "filtering by district" do
      let(:district_id) { "1201" }
      let(:search_params) { { :district_id => district_id } }

      before do
        do_api_request
      end

      it { expect(json.map { |commune| Pumi::Commune.new(commune.delete("id"), commune).district_id }.uniq).to eq([district_id]) }
    end
  end

  describe "'/pumi/villages'" do
    let(:api_endpoint) { Pumi::Engine.routes.url_helpers.villages_path }
    include_examples "api request"

    context "filtering by commune" do
      let(:commune_id) { "120101" }
      let(:search_params) { { :commune_id => commune_id } }

      before do
        do_api_request
      end

      it { expect(json.map { |village| Pumi::Village.new(village.delete("id"), village).commune_id }.uniq).to eq([commune_id]) }
    end
  end
end
