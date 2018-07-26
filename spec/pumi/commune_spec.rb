require "rails_helper"

describe Pumi::Commune do
  subject { described_class.new(sample_id, "name_en" => sample_name_en, "name_km" => sample_name_km) }

  let(:sample_province_id) { "01" }
  let(:sample_district_id) { sample_province_id + "02" }
  let(:sample_id) { sample_district_id + "01" }

  let(:sample_name_en) { "Banteay Neang" }
  let(:sample_name_km) { "បន្ទាយនាង" }
  let(:asserted_number_of_total) { 1634 }
  let(:asserted_number_of_in_province) { 65 }
  let(:asserted_number_of_in_district) { 13 }

  include_examples "location"
  include_examples "district"
  include_examples "commune"
end
