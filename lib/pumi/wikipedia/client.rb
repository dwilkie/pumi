require "faraday"

module Pumi
  module Wikipedia
    class Client
      attr_reader :http_client

      def initialize(http_client: default_http_client)
        @http_client = http_client
      end

      def create_page(params)
        execute_request(:post, build_url(resource: :page, **params))
      end

      def update_page(page_title:, **params)
        page = get_page(page_title:)
        latest = page.fetch(:latest)
        execute_request(:put, build_url(resource: "page/#{page_title}"), latest:, **params)
      end

      def get_page(page_title:)
        execute_request(:get, build_url(resource: "page/#{page_title}"))
      end

      private

      def build_url(resource:, project: :wikipedia, language: :en, **_params)
        "/core/v1/#{project}/#{language}/#{resource}"
      end

      def execute_request(http_method, url, params = {}, headers = {})
        response = http_client.run_request(http_method, url, params.to_json, headers)

        Response.new(response)
      end

      def default_http_client
        Faraday.new(url: "https://api.wikimedia.org") do |conn|
          conn.headers["Accept"] = "application/json"
          conn.headers["Content-Type"] = "application/json"

          conn.adapter Faraday.default_adapter

          conn.request(:authorization, "Bearer", ENV["WIKIPEDIA_ACCESS_TOKEN"])
        end
      end
    end
  end
end
