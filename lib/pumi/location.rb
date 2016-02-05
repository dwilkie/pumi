require_relative "data_set"

class Pumi::Location
  DEFAULT_LOCALE = "km"
  AVAILABLE_LOCALES = [DEFAULT_LOCALE, "en"]

  attr_reader :code, :attributes, :locale

  def initialize(code, locale, attributes = {})
    @code = code
    @locale = (AVAILABLE_LOCALES.include?(locale) && locale) || DEFAULT_LOCALE
    @attributes = attributes
  end

  def self.all(locale = nil)
    data.map { |code, attributes| new(code, locale, attributes) }
  end

  def self.data_set
    @data ||= Pumi::DataSet.new
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
