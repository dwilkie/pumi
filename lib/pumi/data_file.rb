require "yaml"
require "pathname"

module Pumi
  class DataFile
    DEFAULT_DATA_DIRECTORY = File.join(File.expand_path("..", File.dirname(__dir__)), "data")
    TYPES = %w[provinces districts communes villages].freeze

    attr_reader :type

    def initialize(type)
      @type = type.to_s
      raise ArgumentError, "#{type} is not included in #{TYPES}" unless TYPES.include?(@type)
    end

    def read(data_directory: DEFAULT_DATA_DIRECTORY)
      YAML.load_file(data_file(data_directory)).fetch(type)
    end

    def write(data, data_directory: DEFAULT_DATA_DIRECTORY)
      return if data.empty?

      File.write(data_file(data_directory), { type => data.sort.to_h }.to_yaml)
    end

    private

    def data_file(data_directory)
      Pathname(data_directory).join("#{type}.yml")
    end
  end
end
