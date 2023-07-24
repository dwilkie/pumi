require "erb"
require "ostruct"

module Pumi
  module Bot
    module Wikipedia
      class CommuneArticle < Article
        def publish
          template = File.read("#{__dir__}/templates/commune.wikitext.erb")
          commune = Pumi::Commune.all.select { |c| c.geodata.nil? }.first

          data = OpenStruct.new(
            commune:,
            province_page_name: URI.parse(commune.province.links[:wikipedia]).path.split("/").last,
            district_page_name: URI.parse(commune.district.links[:wikipedia]).path.split("/").last,
            lat: commune.geodata&.lat,
            long: commune.geodata&.long,
            villages: Pumi::Village.where(commune_id: commune.id)
          )
          page_content = ERB.new(template).result(data.instance_eval { binding })

          title = commune.full_name_en.gsub(/\s+/, "_")
          title = "Draft:#{title}"

          if client.page_exists?(title:)
            client.update_page(
              title:,
              source: page_content,
              comment: "Update page"
            )
          else
            client.create_page(
              title:,
              source: page_content,
              comment: "Create page for #{commune.full_name_en}"
            )

            client.create_page(
              title: "Draft talk:#{title}",
              source: "{{WikiProject Cambodia}}",
              comment: "Create talk page for #{title}"
            )

            # {{Short description|Commune in Tboung Khmum District, Tboung Khmum Province, Cambodia}}
            # {{Draft topics|southeast-asia}}
            # {{AfC topic|geo}}
          end
        end
      end
    end
  end
end
