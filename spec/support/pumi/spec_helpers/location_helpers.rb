module Pumi::SpecHelpers::LocationHelpers
  def subject
    @subject ||= described_class.new(sample_id, "name_en" => sample_name_en, "name_km" => sample_name_km)
  end
end
