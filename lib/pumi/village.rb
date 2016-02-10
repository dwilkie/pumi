class Pumi::Village < Pumi::Commune
  def self.data
    @@villages ||= from_raw_data(data_set.villages)
  end

  def self.whitelist_search_params(params = {})
    super.merge("commune_id" => normalize_search_param("commune_id", params))
  end

  def commune_id
    id[0..5]
  end

  def commune
    Pumi::Commune.find_by_id(commune_id)
  end
end
