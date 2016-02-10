class Pumi::Commune < Pumi::District
  def self.data
    @@communes ||= from_raw_data(data_set.communes)
  end

  def self.whitelist_search_params(params = {})
    super.merge("district_id" => normalize_search_param("district_id", params))
  end

  def district_id
    id[0..3]
  end

  def district
    Pumi::District.find_by_id(district_id)
  end
end
