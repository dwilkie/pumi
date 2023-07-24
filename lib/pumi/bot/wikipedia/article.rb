module Pumi
  module Bot
    module Wikipedia
      class Article
        attr_reader :client

        def initialize(client: Pumi::Wikipedia::Client.new)
          @client = client
        end
      end
    end
  end
end
