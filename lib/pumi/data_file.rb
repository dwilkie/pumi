require "yaml"
require "pathname"

module Pumi
  class DataFile
    DEFAULT_DATA_DIRECTORY = File.join(File.expand_path("..", File.dirname(__dir__)), "data")
    TYPES = %w[provinces districts communes villages].freeze

    attr_reader :type, :data_directory

    def initialize(type, data_directory: DEFAULT_DATA_DIRECTORY)
      @type = type.to_s
      raise ArgumentError, "#{type} is not included in #{TYPES}" unless TYPES.include?(@type)

      @data_directory = Pathname(data_directory)
    end

    def read
      raw_data
    end

    def write(data)
      return if data.empty?

      File.write(data_file, { type => data.sort.to_h }.to_yaml)
    end

    private

    def raw_data
      @raw_data ||= YAML.load_file(data_file).fetch(type)
    end

    def data_file
      data_directory.join("#{type}.yml")
    end
  end
end
