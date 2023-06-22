require "erb"
require "ostruct"

module Pumi
  module Bot
    class Wikipedia
      attr_reader :client

      def initialize(client: Pumi::Wikipedia::Client.new)
        @client = client
      end

      def publish
        template = File.read("#{__dir__}/templates/commune.wikitext.erb")
        commune = Pumi::Commune.all.last

        data = OpenStruct.new(
          commune:,
          province_page_name: URI.parse(commune.province.links[:wikipedia]).path.split("/").last,
          district_page_name: URI.parse(commune.district.links[:wikipedia]).path.split("/").last,
          villages_count: Pumi::Village.where(commune_id: commune.id).size
        )
        page_content = ERB.new(template).result(data.instance_eval { binding })

        page_title = commune.full_name_en.gsub(/\s+/, "_")
        client.update_page(
          page_title: "Draft:#{page_title}",
          source: page_content,
          comment: "Update page"
        )
      end
    end
  end
end
