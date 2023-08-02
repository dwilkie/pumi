require "spec_helper"
require "pumi/bot/wikipedia"

module Pumi
  module Bot
    module Wikipedia
      RSpec.xdescribe CommunesInCambodiaArticle, :vcr, vcr_options: { tag: :wikipedia_api } do
        describe "#publish", cassette: :update_wikipedia_communes_in_cambodia_article do
          it "updates the article about districts in Cambodia" do
            article = CommunesInCambodiaArticle.new

            article.publish

            expect(WebMock).to(
              have_requested(
                :put,
                "https://api.wikimedia.org/core/v1/wikipedia/en/page/List_of_communes_in_Cambodia"
              ).with do |request|
                request_body = JSON.parse(request.body)
                source = request_body.fetch("source")

                source.include?("current_number = 1,652")
              end
            )
          end
        end
      end
    end
  end
end
