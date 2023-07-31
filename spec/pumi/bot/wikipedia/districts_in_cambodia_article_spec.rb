require "spec_helper"

module Pumi
  module Bot
    module Wikipedia
      RSpec.xdescribe DistrictsInCambodiaArticle, :vcr, vcr_options: { tag: :wikipedia_api } do
        describe "#publish", cassette: :update_wikipedia_districts_in_cambodia_article do
          it "updates the article about districts in Cambodia" do
            article = DistrictsInCambodiaArticle.new

            article.publish

            expect(WebMock).to(
              have_requested(
                :put,
                "https://api.wikimedia.org/core/v1/wikipedia/en/page/List_of_districts,_municipalities_and_sections_in_Cambodia"
              ).with do |request|
                request_body = JSON.parse(request.body)
                source = request_body.fetch("source")

                source.include?("current_number = 208")
              end
            )
          end
        end
      end
    end
  end
end
