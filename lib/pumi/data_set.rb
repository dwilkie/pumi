require 'yaml'

class Pumi::DataSet
  DATA_DIRECTORY = "data"
  DATA_FILE = "villages.yml"

  attr_reader :data

  def initialize
    @data = load_data
  end

  def provinces
    kh_data["provinces"]
  end

  def districts
    kh_data["districts"]
  end

  private

  def kh_data
    data["kh"]
  end

  def load_data
    YAML.load_file(path_to_data)
  end

  def path_to_data
    File.join(File.expand_path('..', File.dirname(__dir__)), DATA_DIRECTORY, DATA_FILE)
  end
end
