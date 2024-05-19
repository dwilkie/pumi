require "ostruct"
require "nokogiri"

module Pumi
  module Bot
    module Wikipedia
      class CommunesInCambodiaArticle < Article
        class Location < SimpleDelegator
          def communes_summary
            summary = communes_by_type.map do |administrative_unit, communes|
              next if Array(communes).empty?

              text = "#{communes.size} #{administrative_unit.name_en}"
              text << "s" if communes.size > 1
              text << " (#{administrative_unit.name_km} #{administrative_unit.name_latin})"
            end

            summary << "#{format_number(villages_count)} Villages (ភូមិ Phum)"

            if summary.size <= 2
              summary.join(" and ")
            else
              [summary[0..-2].join(", "), summary[-1]].join(" and ")
            end
          end

          private

          def communes_by_type
            communes.each_with_object({}) do |commune, result|
              administrative_unit = commune.administrative_unit
              result[administrative_unit] ||= []
              result[administrative_unit] << commune
            end
          end

          def format_number(number)
            number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
          end
        end

        class Province < Location
          def districts
            Pumi::District.where(province_id: id).map { |district| District.new(district) }
          end

          def communes
            Pumi::Commune.where(province_id: id)
          end

          def villages_count
            Pumi::Village.where(province_id: id).count
          end
        end

        class District < Location
          def communes
            Pumi::Commune.where(district_id: id)
          end

          def villages_count
            Pumi::Village.where(district_id: id).count
          end
        end

        PAGE_TITLE = "Draft:List_of_communes_in_Cambodia".freeze
        INTRO_TEXT = "<div id=\"intro\">The '''communes of Cambodia''' ({{lang|km|ឃុំ}} ''[[khum]]''/{{lang|km|សង្កាត់}} ''[[sangkat]]'') are the third-level administrative divisions in  Cambodia. They are the subdivisions of the [[List of districts in Cambodia|districts and municipalities of Cambodia]]. Communes can consist of as few as %<min_villages>s<ref>{{cite web|url=http://db.ncdd.gov.kh/gazetteer/view/commune.castle?cm=%<smallest_commune_id>s |title=%<smallest_commune_name>s |publisher=National Committee for Sub-National Democratic Development }}</ref> or as many as %<max_villages>s<ref>{{cite web|url=http://db.ncdd.gov.kh/gazetteer/view/commune.castle?cm=%<largest_commune_id>s |title=%<largest_commune_name>s |publisher=National Committee for Sub-National Democratic Development }}</ref> villages (''[[phum]]''), depending on the population.\nThere are a total of %<communes_count>s communes and %<villages_count>s villages in Cambodia.</div>".freeze

        TEMPLATE = File.read("#{__dir__}/templates/commune_list.wikitext.erb")

        def publish
          replace_intro
          replace_number_of_communes
          replace_communes_list
          client.update_page(title: PAGE_TITLE, source:, comment: "Update page")
        end

        private

        def source_html
          @source_html ||= Nokogiri::HTML(source)
        end

        def source
          @source ||= page.fetch(:source).dup
        end

        def page
          @page ||= client.get_page(title: PAGE_TITLE)
        end

        def intro_section
          result = source_html.at_css('[id="intro"]')
          raise "Could not find section with <div id=\"intro\">" if result.nil?

          result
        end

        def communes_list_section
          result = source_html.at_css('[id="communes-list"]')
          raise "Could not find section with <div id=\"communes-list\">" if result.nil?

          result
        end

        def replace_communes_list
          provinces = Pumi::Province.all.map { |province| Province.new(province) }
          data = OpenStruct.new(provinces:)
          communes_list = ERB.new(TEMPLATE, trim_mode: "-").result(data.instance_eval { binding })
          source.sub!(communes_list_section.to_html, communes_list)
        end

        def replace_number_of_communes
          source.sub!(
            /current_number\s*=\s*(?:^|\s)(\d*\.?\d+|\d{1,3}(?:,\d{3})*(?:\.\d+)?)(?!\S)/,
            "current_number = #{format_number(Pumi::Commune.all.size)}"
          )
        end

        def replace_intro
          villages = Pumi::Village.all.each_with_object({}) do |village, result|
            result[village.commune] ||= []

            result[village.commune] << village
          end

          village_sizes = villages.each_with_object({}) do |(commune, villages), result|
            result[villages.size] = commune
          end

          min_villages = village_sizes.keys.min
          max_villages = village_sizes.keys.max

          smallest_commune = village_sizes[min_villages]
          largest_commune = village_sizes[max_villages]

          intro = format(
            INTRO_TEXT,
            min_villages:,
            max_villages:,
            smallest_commune_id: smallest_commune.id,
            smallest_commune_name: smallest_commune.name_en,
            largest_commune_id: largest_commune.id,
            largest_commune_name: largest_commune.name_en,
            communes_count: format_number(Pumi::Commune.all.count),
            villages_count: format_number(Pumi::Village.all.count)
          )

          source.sub!(intro_section.to_html, intro)
        end

        def format_number(number)
          number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
        end
      end
    end
  end
end
