require_relative "data_set"

class Pumi::Location
  DEFAULT_LOCALE = "km"
  AVAILABLE_LOCALES = [DEFAULT_LOCALE, "en"]

  attr_reader :id, :attributes, :locale

  def initialize(code, locale, attributes = {})
    @id = code
    @locale = (AVAILABLE_LOCALES.include?(locale.to_s) && locale.to_s) || DEFAULT_LOCALE
    @attributes = attributes
  end

  def self.all(locale = nil)
    data.map { |code, attributes| new(code, locale, attributes) }
  end

  def self.data_set
    @data_set ||= Pumi::DataSet.new
  end

  def self.find_by_id(id)
    new(id, nil, data[id]) if data[id]
  end

  def name
    public_send("name_#{locale}")
  end

  def name_en
    attributes["name_en"]
  end

  def name_km
    attributes["name_km"]
  end
end
