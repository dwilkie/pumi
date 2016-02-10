require 'spec_helper'

describe Pumi::District do
  include Pumi::SpecHelpers::LocationHelpers
  let(:sample_province_id) { "01" }
  let(:sample_id) { sample_province_id + "02" }

  let(:sample_name_en) { "Mongkol Borei" }
  let(:sample_name_km) { "មង្គលបូរី" }
  let(:asserted_number_of_total) { 197 }
  let(:asserted_number_of_in_province) { 9 }

  include_examples "location"
  include_examples "district"
end
