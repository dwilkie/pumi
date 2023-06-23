module Pumi
  module DataSource
    class ISO31662
      attr_reader :data_file

      def initialize(data_file:)
        @data_file = data_file
      end

      def load_data!(output_dir: "data")
        data.each do |code, attributes|
          attributes["iso3166_2"] = "KH-#{code.to_i}"
        end

        write_data!(output_dir)
      end

      private

      def data
        @data ||= data_file.read
      end

      def write_data!(data_directory)
        data_file.write(data, data_directory:)
      end
    end
  end
end
