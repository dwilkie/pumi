require 'yaml'

class Pumi::DataSet
  DATA_DIRECTORY = "data"
  PROVINCES_FILE_NAME = "provinces.yml"
  DISTRICTS_FILE_NAME = "districts.yml"
  COMMUNES_FILE_NAME = "communes.yml"
  VILLAGES_FILE_NAME = "villages.yml"

  attr_reader :provinces, :districts, :communes, :villages

  def initialize
    @provinces = load_data(PROVINCES_FILE_NAME)["provinces"]
    @districts = load_data(DISTRICTS_FILE_NAME)["districts"]
    @communes  = load_data(COMMUNES_FILE_NAME)["communes"]
    @villages  = load_data(VILLAGES_FILE_NAME)["villages"]
  end

  def self.data_path(filename)
    File.join(File.expand_path('..', File.dirname(__dir__)), DATA_DIRECTORY, filename)
  end

  private

  def load_data(filename)
    YAML.load_file(self.class.data_path(filename))
  end
end
