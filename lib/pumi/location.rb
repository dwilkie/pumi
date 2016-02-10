require_relative "data_set"

class Pumi::Location
  attr_reader :id, :name_en, :name_km

  def initialize(code, attributes = {})
    @id = code
    @name_en = attributes["name_en"]
    @name_km = attributes["name_km"]
  end

  def self.all
    data.values
  end

  def self.find_by_id(id)
    data[id]
  end

  def self.where(params = {})
    search_params = whitelist_search_params(params).delete_if { |k, v| v.empty? }

    localized_data = all
    return localized_data if search_params.empty?

    localized_data.select do |location|
      select = true
      search_params.each do |search_param, search_value|
        select = select && (search_value == location.public_send(search_param))
      end
      select
    end
  end

  private

  def self.from_raw_data(raw_data)
    Hash[raw_data.map { |id, attributes| [id, new(id, attributes)] }]
  end

  def self.whitelist_search_params(params = {})
    {
      "name_en" => normalize_search_param("name_en", params),
      "name_km" => normalize_search_param("name_km", params),
      "id" =>      normalize_search_param("id", params)
    }
  end

  def self.normalize_search_param(key, params = {})
    (params[key.to_s] || params[key.to_sym]).to_s
  end

  def self.data_set
    Pumi::DataSet.new
  end

  private_class_method :whitelist_search_params, :normalize_search_param, :data_set
end
