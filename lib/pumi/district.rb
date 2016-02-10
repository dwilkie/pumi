class Pumi::District < Pumi::Location
  def self.data
    @districts ||= from_raw_data(data_set.districts)
  end

  def self.whitelist_search_params(params = {})
    super.merge("province_id" => normalize_search_param("province_id", params))
  end

  def province_id
    id[0..1]
  end

  def province
    Pumi::Province.find_by_id(province_id)
  end
end
