require "pry"
require "ostruct"

module Pumi
  module Bot
    module Wikipedia
      class DistrictsInCambodiaArticle < Article
        PAGE_TITLE = "List_of_districts,_municipalities_and_sections_in_Cambodia".freeze

        INTRO_TEXT = "This is a list of [[Cambodia]]'s %<districts_count>s districts ({{lang|km|ស្រុក}} ''srok''), %<municipalities_count>s district-level municipalities ({{lang|km|ក្រុង}} ''krong'') and %<sections_count>s sections ({{lang|km|ខណ្ឌ}} ''khan'') organized by each [[Provinces of Cambodia|province]] and an [[Provinces of Cambodia|autonomous municipality]] ([[Phnom Penh]]).".freeze
        DISTRICTS_TEMPLATE = File.read("#{__dir__}/templates/district_list.wikitext.erb")

        Misspelling = Struct.new(:incorrect_text, :correct_text, keyword_init: true)

        MISSPELLINGS = [
          Misspelling.new(incorrect_text: "Kratié", correct_text: "Kratie"),
          Misspelling.new(incorrect_text: "Mondulkiri", correct_text: "Mondul Kiri"),
          Misspelling.new(
            incorrect_text: "Phnom Penh (autonomous municipality)",
            correct_text: "Phnom Penh"
          ),
          Misspelling.new(incorrect_text: "Ratanakiri", correct_text: "Ratanak Kiri"),
          Misspelling.new(incorrect_text: "Siem Reap", correct_text: "Siemreap"),
          Misspelling.new(incorrect_text: "Takéo", correct_text: "Takeo")
        ].freeze

        def publish
          page = client.get_page(title: PAGE_TITLE)
          source = page.fetch(:source).dup

          replace_intro(source:, replacement: generate_intro)
          replace_number_of_districts(source:, replacement: District.all.size)

          Pumi::Province.all.each do |province|
            section = find_section_by_title(source:, title: province.name_en)
            new_section = generate_districts_section(province:)
            source.sub!(section[1], new_section)
          end

          client.update_page(title: PAGE_TITLE, source:, comment: "Update page")
        end

        private

        def generate_districts_section(province:)
          districts = Pumi::District.where(province_id: province.id)

          data = OpenStruct.new(
            province:,
            districts:,
            districts_summary: generate_districts_summary(districts:)
          )
          result = ERB.new(DISTRICTS_TEMPLATE).result(data.instance_eval { binding })
          "\n\n#{result}\n"
        end

        def generate_districts_summary(districts:)
          summary = districts_by_type(collection: districts).map do |au, d|
            next if Array(d).empty?

            text = "#{d.size} #{au.name_en}"
            if d.size > 1
              au.name_en.end_with?("y") ? text.chomp!("y") << "ies" : text << "s"
            end
            text << " (#{au.name_km} #{au.name_latin})"
          end

          if summary.size <= 2
            summary.join(" and ")
          else
            [summary[0..-2].join(", "), summary[-1]].join(" and ")
          end
        end

        def find_section_by_title(source:, title:)
          misspelling = MISSPELLINGS.find { |m| m.correct_text == title }
          search_term = misspelling&.incorrect_text || title

          section = source.match(/==\s*\[\[[[:word:]\s]+\|#{Regexp.escape(search_term)}\]\].+?==(.+?(?===))/m)

          raise "Missing section for #{search_term}" if section.nil?

          section
        end

        def generate_intro
          all_districts = districts_by_type

          format(
            INTRO_TEXT,
            districts_count: fetch_districts_by_type("District", collection: all_districts).size,
            municipalities_count: fetch_districts_by_type(
              "Municipality",
              collection: all_districts
            ).size,
            sections_count: fetch_districts_by_type("Section", collection: all_districts).size
          )
        end

        def replace_number_of_districts(source:, replacement:)
          source.sub!(/current_number\s*=\s*\d+/, "current_number = #{replacement}")
        end

        def replace_intro(source:, replacement:)
          source.sub!(/This is a list of.+/, replacement)
        end

        def districts_by_type(collection: Pumi::District.all)
          collection.each_with_object({}) do |district, result|
            administrative_unit = district.administrative_unit
            result[administrative_unit] ||= []
            result[administrative_unit] << district
          end
        end

        def fetch_districts_by_type(type, collection:)
          administrative_unit = collection.keys.find { |au| au.name_en == type }
          Array(collection[administrative_unit])
        end
      end
    end
  end
end
