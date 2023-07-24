require "spec_helper"

module Pumi
  module Bot
    module Wikipedia
      RSpec.describe CommunesInCambodiaArticle, :allow_network_requests do
        describe "#publish", cassette: :wikipedia_districts_in_cambodia_article do
          it "publishes an article about districts in Cambodia" do
            article = CommunesInCambodiaArticle.new

            article.publish
          end
        end
      end
    end
  end
end
