require "rails_helper"

describe Pumi::Village do
  subject { described_class.new(sample_id, "name_en" => sample_name_en, "name_km" => sample_name_km) }

  let(:sample_province_id) { "01" }
  let(:sample_district_id) { sample_province_id + "02" }
  let(:sample_commune_id) { sample_district_id + "01" }
  let(:sample_id) { sample_commune_id + "01" }

  let(:sample_name_en) { "Ou Thum" }
  let(:sample_name_km) { "អូរធំ" }
  let(:asserted_number_of_total) { 14245 }
  let(:asserted_number_of_in_province) { 645 }
  let(:asserted_number_of_in_district) { 157 }
  let(:asserted_number_of_in_commune) { 19 }

  include_examples "location"
  include_examples "district"
  include_examples "commune"
  include_examples "village"
end
