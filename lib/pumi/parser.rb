require "yaml"

module Pumi
  class Parser
    DATA_DIRECTORY = Pathname.new(File.expand_path("..", File.dirname(__dir__))).join("data")

    def load(key)
      YAML.load_file(DATA_DIRECTORY.join("#{key}.yml")).fetch(key.to_s)
    end
  end
end
