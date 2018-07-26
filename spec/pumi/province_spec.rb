require "rails_helper"

describe Pumi::Province do
  subject { described_class.new(sample_id, "name_en" => sample_name_en, "name_km" => sample_name_km) }

  let(:sample_id) { "01" }
  let(:sample_name_en) { "Banteay Meanchey" }
  let(:sample_name_km) { "បន្ទាយមានជ័យ" }
  let(:asserted_number_of_total) { 25 }

  include_examples "location"
end
