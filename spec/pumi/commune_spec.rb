require 'spec_helper'

describe Pumi::Commune do
  include Pumi::SpecHelpers::LocationHelpers

  let(:sample_province_id) { "01" }
  let(:sample_district_id) { sample_province_id + "02" }
  let(:sample_id) { sample_district_id + "01" }

  let(:sample_name_en) { "Banteay Neang" }
  let(:sample_name_km) { "បន្ទាយនាង" }
  let(:asserted_number_of_total) { 1621 }
  let(:asserted_number_of_in_province) { 64 }
  let(:asserted_number_of_in_district) { 13 }

  include_examples "location"
  include_examples "district"
  include_examples "commune"
end
