module Pumi
  module Publisher
    class Wikipedia
      attr_reader :client

      def initialize(client: Wikipedia::Client.new)
        @client = client
      end

      def publish; end
    end
  end
end
