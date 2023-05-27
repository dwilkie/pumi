require "nokogiri"
require "open-uri"

module Pumi
  module DataSource
    class Wikipedia
      attr_reader :data_file, :scraper

      def initialize(data_file:, scraper:)
        @data_file = data_file
        @scraper = scraper
      end

      def load_data!(output_dir: "data")
        data.each do |code, attributes|
          location_data = scraped_data.find { |location| location.code == code }
          next unless location_data

          attributes["links"] ||= {}
          attributes["links"]["wikipedia"] = location_data.wikipedia
        end

        write_data!(output_dir)
      end

      private

      def scraped_data
        @scraped_data ||= scraper.scrape!
      end

      def data
        @data ||= data_file.read
      end

      def write_data!(data_directory)
        data_file.write(data, data_directory:)
      end

      ScraperResult = Struct.new(:code, :wikipedia, keyword_init: true)

      class WebScraper
        class ElementNotFoundError < StandardError; end

        attr_reader :url

        def initialize(url)
          @url = url
        end

        def page
          @page ||= Nokogiri::HTML(URI.parse(url).open)
        end
      end

      class CambodianProvincesScraper
        URL = "https://en.wikipedia.org/wiki/Provinces_of_Cambodia".freeze

        def scrape!
          Province.all.each_with_object([]) do |province, result|
            result << ScraperResult.new(code: province.id, wikipedia: find_url(province))
          end
        end

        private

        def scraper
          @scraper ||= WebScraper.new(URL)
        end

        def find_url(province)
          td = province_table_rows.xpath("child::td[contains(., '#{province.name_km}')]").first
          if td.nil?
            raise WebScraper::ElementNotFoundError,
                  "No cell containing '#{province.name_km}' was found in a table on #{URL}"
          end

          link = td.xpath("preceding-sibling::td/a").first
          URI.join(URL, link[:href]).to_s
        end

        def province_table_rows
          @province_table_rows ||= begin
            sample_province = Province.all.first

            sample_row = scraper.page.xpath("//table/tbody/tr[td//text()[contains(., '#{sample_province.name_km}')]]").first
            if sample_row.xpath("//a[text()[contains(., '#{sample_province.name_en}')]]").empty?
              raise WebScraper::ElementNotFoundError,
                    "No link containing '#{sample_province.name_en}' was found in a table on #{URL}"
            end

            sample_row.parent.xpath("child::tr")
          end
        end
      end

      class CambodianDistrictsScraper
        URL = "https://en.wikipedia.org/wiki/List_of_districts,_municipalities_and_sections_in_Cambodia".freeze

        def scrape!
          District.all.each_with_object([]) do |district, result|
            url = find_url(district)
            next unless url

            result << ScraperResult.new(code: district.id, wikipedia: url)
          end
        end

        private

        def scraper
          @scraper ||= WebScraper.new(URL)
        end

        def find_url(district)
          identifier = district.id.chars.each_slice(2).map(&:join).join("-")
          list_items = scraper.page.xpath("//ol/li[text()[contains(., '#{identifier}')]]")

          return if list_items.empty?

          if list_items.size > 1
            raise WebScraper::ElementNotFoundError,
                  "More than one element was found with the identifier '#{identifier}' on #{URL}"
          end

          link = list_items.first.xpath("child::a[contains(@href, '/wiki/')]").first
          return unless link

          URI.join(URL, link[:href]).to_s
        end
      end

      class CambodianCommunesScraper
        class CommuneNotFoundError < StandardError; end
        class DuplicateCommuneError < StandardError; end

        URL = "https://en.wikipedia.org/wiki/List_of_communes_in_Cambodia".freeze
        Misspelling = Struct.new(:incorrect_text, :correct_text, keyword_init: true)
        InvalidCommuneLink = Struct.new(:district_code, :name, keyword_init: true)

        MISSING_LOCATIONS = [
          "Taing Kouk District",
          "Bokor Municipality",
          "Ta Lou Senchey District",
          "Kaoh Rung Municipality",
          "Borei Ou Svay Senchey District"
        ].freeze

        INVALID_COMMUNE_LINKS = [
          InvalidCommuneLink.new(district_code: "0301", name: "Prasat"),
          InvalidCommuneLink.new(district_code: "0302", name: "Svay Teab"),
          InvalidCommuneLink.new(district_code: "0306", name: "Kokor"),
          InvalidCommuneLink.new(district_code: "0306", name: "Krala"),
          InvalidCommuneLink.new(district_code: "0307", name: "Angkor Ban"),
          InvalidCommuneLink.new(district_code: "0307", name: "Sdau"),
          InvalidCommuneLink.new(district_code: "0308", name: "Koh Sotin"),
          InvalidCommuneLink.new(district_code: "0601", name: "Treal"),
          InvalidCommuneLink.new(district_code: "0601", name: "Baray"),
          InvalidCommuneLink.new(district_code: "0313", name: "Mean"),
          InvalidCommuneLink.new(district_code: "0313", name: "Lvea"),
          InvalidCommuneLink.new(district_code: "0313", name: "Prey Chor"),
          InvalidCommuneLink.new(district_code: "0314", name: "Baray"),
          InvalidCommuneLink.new(district_code: "0314", name: "Mean Chey"),
          InvalidCommuneLink.new(district_code: "0401", name: "Ponley"),
          InvalidCommuneLink.new(district_code: "0405", name: "Longveaek"),
          InvalidCommuneLink.new(district_code: "0405", name: "Saeb"),
          InvalidCommuneLink.new(district_code: "0406", name: "Svay Chrum"),
          InvalidCommuneLink.new(district_code: "0501", name: "Basedth"),
          InvalidCommuneLink.new(district_code: "0503", name: "Srang"),
          InvalidCommuneLink.new(district_code: "0503", name: "Veal"),
          InvalidCommuneLink.new(district_code: "0507", name: "Samraong Tong"),
          InvalidCommuneLink.new(district_code: "0510", name: "Mean Chey"),
          InvalidCommuneLink.new(district_code: "0510", name: "Phnum Touch"),
          InvalidCommuneLink.new(district_code: "0606", name: "Chheu Teal"),
          InvalidCommuneLink.new(district_code: "0606", name: "Klaeng"),
          InvalidCommuneLink.new(district_code: "0606", name: "Mean Chey"),
          InvalidCommuneLink.new(district_code: "0608", name: "Trea"),
          InvalidCommuneLink.new(district_code: "0604", name: "Daung"),
          InvalidCommuneLink.new(district_code: "0606", name: "Sandaan"),
          InvalidCommuneLink.new(district_code: "0607", name: "Kokoh"),
          InvalidCommuneLink.new(district_code: "0701", name: "Angkor Chey"),
          InvalidCommuneLink.new(district_code: "0703", name: "Chhouk"),
          InvalidCommuneLink.new(district_code: "0703", name: "Meanchey"),
          InvalidCommuneLink.new(district_code: "0708", name: "Kampong Bay"),
          InvalidCommuneLink.new(district_code: "0801", name: "Siem Reap"),
          InvalidCommuneLink.new(district_code: "0801", name: "Trea"),
          InvalidCommuneLink.new(district_code: "0802", name: "Chheu Teal"),
          InvalidCommuneLink.new(district_code: "0802", name: "Kokir"),
          InvalidCommuneLink.new(district_code: "0804", name: "Leuk Daek"),
          InvalidCommuneLink.new(district_code: "0808", name: "Mkak"),
          InvalidCommuneLink.new(district_code: "0809", name: "Ponhea Leu"),
          InvalidCommuneLink.new(district_code: "0811", name: "Ta Khmau"),
          InvalidCommuneLink.new(district_code: "0813", name: "Svay Chrum"),
          InvalidCommuneLink.new(district_code: "0904", name: "Smach Meanchey"),
          InvalidCommuneLink.new(district_code: "0906", name: "Srae Ambel"),
          InvalidCommuneLink.new(district_code: "1001", name: "Chhloung"),
          InvalidCommuneLink.new(district_code: "1003", name: "Preaek Prasab"),
          InvalidCommuneLink.new(district_code: "1003", name: "Tamao"),
          InvalidCommuneLink.new(district_code: "1004", name: "Sombo"),
          InvalidCommuneLink.new(district_code: "1006", name: "Sambok"),
          InvalidCommuneLink.new(district_code: "1303", name: "Choam Khsant"),
          InvalidCommuneLink.new(district_code: "1304", name: "Phnom Penh"),
          InvalidCommuneLink.new(district_code: "1305", name: "Ratanak"),
          InvalidCommuneLink.new(district_code: "1308", name: "Pahal"),
          InvalidCommuneLink.new(district_code: "1403", name: "Kampong Trabaek"),
          InvalidCommuneLink.new(district_code: "1403", name: "Prey Chhor"),
          InvalidCommuneLink.new(district_code: "1404", name: "Kanhchriech"),
          InvalidCommuneLink.new(district_code: "1405", name: "Svay Chrum"),
          InvalidCommuneLink.new(district_code: "1409", name: "Lvea"),
          InvalidCommuneLink.new(district_code: "1409", name: "Preah Sdach"),
          InvalidCommuneLink.new(district_code: "1410", name: "Baray"),
          InvalidCommuneLink.new(district_code: "1410", name: "Kampong Leav"),
          InvalidCommuneLink.new(district_code: "1411", name: "Takor"),
          InvalidCommuneLink.new(district_code: "1502", name: "Anlong Vil"),
          InvalidCommuneLink.new(district_code: "1502", name: "Kandieng"),
          InvalidCommuneLink.new(district_code: "1502", name: "Sya"),
          InvalidCommuneLink.new(district_code: "1502", name: "Veal"),
          InvalidCommuneLink.new(district_code: "1604", name: "Teun"),
          InvalidCommuneLink.new(district_code: "1606", name: "Poy"),
          InvalidCommuneLink.new(district_code: "1607", name: "Sesan"),
          InvalidCommuneLink.new(district_code: "1607", name: "Yatung"),
          InvalidCommuneLink.new(district_code: "1609", name: "Pong"),
          InvalidCommuneLink.new(district_code: "1609", name: "Veun Sai"),
          InvalidCommuneLink.new(district_code: "1701", name: "Koal"),
          InvalidCommuneLink.new(district_code: "1702", name: "Svay Chek"),
          InvalidCommuneLink.new(district_code: "1704", name: "Chi Kraeng"),
          InvalidCommuneLink.new(district_code: "1704", name: "Kampong Kdei"),
          InvalidCommuneLink.new(district_code: "1706", name: "Kralanh"),
          InvalidCommuneLink.new(district_code: "1706", name: "Sen Sok"),
          InvalidCommuneLink.new(district_code: "1707", name: "Lvea"),
          InvalidCommuneLink.new(district_code: "1707", name: "Reul"),
          InvalidCommuneLink.new(district_code: "1709", name: "Bakong"),
          InvalidCommuneLink.new(district_code: "1709", name: "Meanchey"),
          InvalidCommuneLink.new(district_code: "1710", name: "Nokor Thom"),
          InvalidCommuneLink.new(district_code: "1711", name: "Popel"),
          InvalidCommuneLink.new(district_code: "1713", name: "Svay Leu"),
          InvalidCommuneLink.new(district_code: "1801", name: "Koh Rong"),
          InvalidCommuneLink.new(district_code: "1802", name: "Ou Chrov"),
          InvalidCommuneLink.new(district_code: "1802", name: "Prey Nob"),
          InvalidCommuneLink.new(district_code: "1802", name: "Ream"),
          InvalidCommuneLink.new(district_code: "1804", name: "Kampong Seila"),
          InvalidCommuneLink.new(district_code: "1901", name: "Sdau"),
          InvalidCommuneLink.new(district_code: "1902", name: "Siem Bouk"),
          InvalidCommuneLink.new(district_code: "1903", name: "Sekong"),
          InvalidCommuneLink.new(district_code: "2001", name: "Chantrea"),
          InvalidCommuneLink.new(district_code: "2002", name: "Preah Ponlea"),
          InvalidCommuneLink.new(district_code: "2003", name: "Svay Chek"),
          InvalidCommuneLink.new(district_code: "2004", name: "Ampel"),
          InvalidCommuneLink.new(district_code: "2004", name: "Daung"),
          InvalidCommuneLink.new(district_code: "2004", name: "Kampong Trach"),
          InvalidCommuneLink.new(district_code: "2004", name: "Kokir"),
          InvalidCommuneLink.new(district_code: "2004", name: "Krasang"),
          InvalidCommuneLink.new(district_code: "2005", name: "Bassak"),
          InvalidCommuneLink.new(district_code: "2005", name: "Chheu Teal"),
          InvalidCommuneLink.new(district_code: "2005", name: "Svay Chrum"),
          InvalidCommuneLink.new(district_code: "2008", name: "Bavet"),
          InvalidCommuneLink.new(district_code: "2008", name: "Prasat"),
          InvalidCommuneLink.new(district_code: "2201", name: "Anlong Veaeng"),
          InvalidCommuneLink.new(district_code: "2401", name: "Pailin"),
          InvalidCommuneLink.new(district_code: "2502", name: "Chhouk"),
          InvalidCommuneLink.new(district_code: "2502", name: "Trea"),
          InvalidCommuneLink.new(district_code: "2503", name: "Memot"),
          InvalidCommuneLink.new(district_code: "2503", name: "Kokir"),
          InvalidCommuneLink.new(district_code: "2504", name: "Chork"),
          InvalidCommuneLink.new(district_code: "2504", name: "Mean"),
          InvalidCommuneLink.new(district_code: "2505", name: "Popel"),
          InvalidCommuneLink.new(district_code: "2507", name: "Chikor")
        ].freeze

        MISSPELLINGS = [
          Misspelling.new(incorrect_text: "Kratié Province", correct_text: "Kratie Province"),
          Misspelling.new(
            incorrect_text: "Mondulkiri Province",
            correct_text: "Mondul Kiri Province"
          ),
          Misspelling.new(
            incorrect_text: "Ratanakiri Province",
            correct_text: "Ratanak Kiri Province"
          ),
          Misspelling.new(
            incorrect_text: "Siem Reap Province",
            correct_text: "Siemreap Province"
          ),
          Misspelling.new(
            incorrect_text: "Serei Saophoan District",
            correct_text: "Serei Saophoan Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Poipet Municipality",
            correct_text: "Paoy Paet Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Battambang District",
            correct_text: "Battambang Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Rotanak Mondol District",
            correct_text: "Rotonak Mondol District"
          ),
          Misspelling.new(
            incorrect_text: "Sampov Loun District",
            correct_text: "Sampov Lun District"
          ),
          Misspelling.new(
            incorrect_text: "Koh Kralor District",
            correct_text: "Koas Krala District"
          ),
          Misspelling.new(
            incorrect_text: "Rukhak Kiri District",
            correct_text: "Rukh Kiri District"
          ),
          Misspelling.new(
            incorrect_text: "Koh Sotin District",
            correct_text: "Kaoh Soutin District"
          ),
          Misspelling.new(
            incorrect_text: "Srey Santhor District",
            correct_text: "Srei Santhor District"
          ),
          Misspelling.new(
            incorrect_text: "Kong Pisey",
            correct_text: "Kong Pisei District"
          ),
          Misspelling.new(
            incorrect_text: "Phnom Sruoch District",
            correct_text: "Phnum Sruoch District"
          ),
          Misspelling.new(
            incorrect_text: "Stueng Saen District",
            correct_text: "Stueng Saen Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Prasat Balangk District",
            correct_text: "Prasat Ballangk District"
          ),
          Misspelling.new(
            incorrect_text: "Kampot District",
            correct_text: "Kampot Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Kampot District",
            correct_text: "Kampot Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Koh Thum District",
            correct_text: "Kaoh Thum District"
          ),
          Misspelling.new(
            incorrect_text: "Mukh Kamphool District",
            correct_text: "Mukh Kampul District"
          ),
          Misspelling.new(
            incorrect_text: "Ponhea Leu District",
            correct_text: "Ponhea Lueu District"
          ),
          Misspelling.new(
            incorrect_text: "Kiri Sakor",
            correct_text: "Kiri Sakor District"
          ),
          Misspelling.new(
            incorrect_text: "Koh Kong",
            correct_text: "Kaoh Kong District"
          ),
          Misspelling.new(
            incorrect_text: "Khemara Phoumin",
            correct_text: "Khemara Phoumin Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Mondol Seima",
            correct_text: "Mondol Seima District"
          ),
          Misspelling.new(
            incorrect_text: "Srae Ambel",
            correct_text: "Srae Ambel District"
          ),
          Misspelling.new(
            incorrect_text: "Thma Bang",
            correct_text: "Thma Bang District"
          ),
          Misspelling.new(
            incorrect_text: "Kratie Municipality",
            correct_text: "Kracheh Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Preaek Prasab District",
            correct_text: "Prek Prasab District"
          ),
          Misspelling.new(
            incorrect_text: "Krong Saen Monorom",
            correct_text: "Saen Monourom Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Khan Daun Penh",
            correct_text: "Doun Penh Section"
          ),
          Misspelling.new(
            incorrect_text: "Khan Prampir Makara",
            correct_text: "Prampir Meakkakra Section"
          ),
          Misspelling.new(
            incorrect_text: "Khan Meanchey",
            correct_text: "Mean Chey Section"
          ),
          Misspelling.new(
            incorrect_text: "Khan Sen Sok",
            correct_text: "Saensokh Section"
          ),
          Misspelling.new(
            incorrect_text: "Khan Por Sen Chey",
            correct_text: "Pur SenChey Section"
          ),
          Misspelling.new(
            incorrect_text: "Khan Chrouy Changvar",
            correct_text: "Chraoy Chongvar Section"
          ),
          Misspelling.new(
            incorrect_text: "Khan Prek Phnov",
            correct_text: "Praek Pnov Section"
          ),
          Misspelling.new(
            incorrect_text: "Choam Khsant",
            correct_text: "Choam Ksant District"
          ),
          Misspelling.new(
            incorrect_text: "Kulen",
            correct_text: "Kuleaen District"
          ),
          Misspelling.new(
            incorrect_text: "Sangkom Thmei",
            correct_text: "Sangkum Thmei District"
          ),
          Misspelling.new(
            incorrect_text: "Prey Veaeng",
            correct_text: "Prey Veng Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Por Reang",
            correct_text: "Pur Rieng District"
          ),
          Misspelling.new(
            incorrect_text: "Veal Veng",
            correct_text: "Veal Veaeng District"
          ),
          Misspelling.new(
            incorrect_text: "Krong Banlung",
            correct_text: "Ban Lung Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Angkor Thom",
            correct_text: "Angkor Thum District"
          ),
          Misspelling.new(
            incorrect_text: "Sout Nikom",
            correct_text: "Soutr Nikom District"
          ),
          Misspelling.new(
            incorrect_text: "Steung Hav",
            correct_text: "Stueng Hav District"
          ),
          Misspelling.new(
            incorrect_text: "Krong Stung Treng",
            correct_text: "Stueng Traeng Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Bourei Cholsar District",
            correct_text: "Borei Cholsar District"
          ),
          Misspelling.new(
            incorrect_text: "Damnak Chang'Eur",
            correct_text: "Damnak Chang'aeur District"
          ),
          Misspelling.new(
            incorrect_text: "Krong Keb",
            correct_text: "Kaeb Municipality"
          ),
          Misspelling.new(
            incorrect_text: "Sala Krao",
            correct_text: "Sala Krau District"
          ),
          Misspelling.new(
            incorrect_text: "Dombae",
            correct_text: "Dambae District"
          ),
          Misspelling.new(
            incorrect_text: "Krouch Chhma",
            correct_text: "Krouch Chhmar District"
          ),
          Misspelling.new(incorrect_text: "Paoy Char", correct_text: "Poy Char"),
          Misspelling.new(incorrect_text: "Phnom Dei", correct_text: "Phnum Dei"),
          Misspelling.new(incorrect_text: "Spean Sraeng Rouk", correct_text: "Spean Sraeng"),
          Misspelling.new(incorrect_text: "Chhnuor", correct_text: "Chnuor Mean Chey"),
          Misspelling.new(incorrect_text: "Chob", correct_text: "Chob Vari"),
          Misspelling.new(incorrect_text: "Prasat Char", correct_text: "Prasat"),
          Misspelling.new(incorrect_text: "Preah Netr Preah", correct_text: "Preak Netr Preah"),
          Misspelling.new(incorrect_text: "Rohal Rohal", correct_text: "Rohal"),
          Misspelling.new(incorrect_text: "Tuek Chour Smach", correct_text: "Tuek Chour"),
          Misspelling.new(incorrect_text: "Ou Bei Choan", correct_text: "Ou Beichoan"),
          Misspelling.new(incorrect_text: "Ou Sampor", correct_text: "Ou Sampoar"),
          Misspelling.new(incorrect_text: "Poipet", correct_text: "Paoy Paet"),
          Misspelling.new(incorrect_text: "Tuol Ta Aek", correct_text: "Tuol Ta Ek"),
          Misspelling.new(incorrect_text: "Preaek Preah Sdach", correct_text: "Tuol Ta Ek"),
          Misspelling.new(incorrect_text: "Chamkar Samraong", correct_text: "Chomkar Somraong"),
          Misspelling.new(incorrect_text: "Sla Kaet", correct_text: "Sla Ket"),
          Misspelling.new(incorrect_text: "Ou Mal", correct_text: "OMal"),
          Misspelling.new(incorrect_text: "Voat Kor", correct_text: "wat Kor"),
          Misspelling.new(incorrect_text: "Svay Pao", correct_text: "Svay Por"),
          Misspelling.new(incorrect_text: "Kdol Tahen", correct_text: "Kdol Ta Haen"),
          Misspelling.new(incorrect_text: "Kaoh Chiveang Thvang", correct_text: "Kaoh Chiveang"),
          Misspelling.new(incorrect_text: "Voat Ta Muem", correct_text: "Vaot Ta Muem"),
          Misspelling.new(incorrect_text: "Ou Samrel", correct_text: "Ou Samril"),
          Misspelling.new(incorrect_text: "Ta Krai", correct_text: "Ta Krei"),
          Misspelling.new(incorrect_text: "Prek Chik", correct_text: "Preaek Chik"),
          Misspelling.new(incorrect_text: "Prey Chor", correct_text: "Prey Chhor"),
          Misspelling.new(incorrect_text: "Samraong Tong", correct_text: "Samrong Tong"),
          Misspelling.new(incorrect_text: "Phnum Touch", correct_text: "Phnom Touch"),
          Misspelling.new(incorrect_text: "Tonle Bassac", correct_text: "Tonle Basak"),
          Misspelling.new(incorrect_text: "Chey Chumneas", correct_text: "Chey Chummeah"),
          Misspelling.new(incorrect_text: "Boeung Prolit", correct_text: "Boeng Proluet"),
          Misspelling.new(incorrect_text: "Tuol Svay Prey 2",
                          correct_text: "Tuol Svay Prey Ti Pir"),
          Misspelling.new(incorrect_text: "Neak Leung", correct_text: "Neak Loeang"),
          Misspelling.new(incorrect_text: "Kratie", correct_text: "Kracheh"),
          Misspelling.new(incorrect_text: "Pate", correct_text: "Pa Te"),
          Misspelling.new(incorrect_text: "Prek Phtoul Commune", correct_text: "Preaek Phtoul"),
          Misspelling.new(incorrect_text: "Bourei Cholsar Commune", correct_text: "Borei Cholsar"),
          Misspelling.new(
            incorrect_text: "Kampeaeng Commune (Kiri Vong District)",
            correct_text: "Kampeaeng"
          ),
          Misspelling.new(
            incorrect_text: "Prey Rumdeng Commune (Kiri Vong District)",
            correct_text: "Prey Rumdeng"
          ),
          Misspelling.new(incorrect_text: "Ta Our Commune", correct_text: "Ta Ou"),
          Misspelling.new(incorrect_text: "Kompaeng Commune", correct_text: "Kampeaeng"),
          Misspelling.new(incorrect_text: "Kompong Reab Commune", correct_text: "Kampong Reab"),
          Misspelling.new(incorrect_text: "Our Saray Commune", correct_text: "Ou Saray"),
          Misspelling.new(
            incorrect_text: "Trapeang Kranhung Commune",
            correct_text: "Trapeang Kranhoung"
          ),
          Misspelling.new(incorrect_text: "Angk Kev Commune", correct_text: "Angk Kaev"),
          Misspelling.new(incorrect_text: "Sanlong Commune", correct_text: "Sanlung"),
          Misspelling.new(incorrect_text: "O Smach", correct_text: "Ou Smach")
        ].freeze

        def scrape!
          result = []

          District.all.each do |district|
            province_section = find_section(
              text: district.province.address_en,
              section: scraper.page,
              xpath_pattern: "//h2//a[text()[contains(., \"%<text>s\")]]"
            ).xpath("ancestor::h2/following-sibling::div").first

            district_title = find_section(
              text: [district.full_name_en, district.full_name_latin, district.name_latin],
              section: province_section,
              xpath_pattern: "child::table//tr/td//h3//*[text()[contains(., \"%<text>s\")]]"
            )

            next unless district_title

            district_section = district_title.xpath("ancestor::h3/following-sibling::*").first
            commune_links = district_section.xpath("child::li//a[contains(@href, '/wiki/')]")

            commune_links.each do |link|
              invalid_commune_link = find_invalid_commune_link(district:, text: link.text)

              next if invalid_commune_link

              commune = begin
                find_commune(
                  district:,
                  names: {
                    name_latin: link.text,
                    full_name_en: link.text,
                    full_name_latin: link.text
                  }
                )
              rescue CommuneNotFoundError => e
                misspelling = MISSPELLINGS.find do |m|
                  m.incorrect_text == link.text
                end

                raise(e) unless misspelling

                find_commune(district:, names: { name_latin: misspelling.correct_text })
              end

              result << ScraperResult.new(code: commune.id,
                                          wikipedia: URI.join(
                                            URL, link[:href]
                                          ).to_s)
            end
          end

          result
        end

        private

        def build_commune_links(district:, pool:); end

        def find_invalid_commune_link(district:, text:)
          INVALID_COMMUNE_LINKS.find do |c|
            c.district_code == district.id && c.name == text
          end
        end

        def find_section(text:, section:, xpath_pattern:)
          texts = Array(text)
          default_text = texts.first
          texts.each do |t|
            return find_link(text: t, section:, xpath_pattern:)
          rescue WebScraper::ElementNotFoundError => e
            raise(e) if t == texts.last
          end
        rescue WebScraper::ElementNotFoundError => e
          misspelling = MISSPELLINGS.find do |m|
            m.correct_text == default_text
          end

          return if !misspelling && MISSING_LOCATIONS.include?(default_text)
          raise(e) unless misspelling

          find_link(text: misspelling.incorrect_text, section:, xpath_pattern:)
        end

        def find_link(text:, section:, xpath_pattern:)
          xpath = format(xpath_pattern, text:)
          result = section.xpath(xpath)

          return result.first if result.size == 1

          raise WebScraper::ElementNotFoundError,
                "No link or many links found on #{URL} (xpath: '#{xpath}') "
        end

        def find_commune(district:, names:)
          results = []
          names.each do |k, v|
            results = Commune.where(district_id: district.id, k => v)

            break unless results.empty?
          end

          raise CommuneNotFoundError if results.empty?

          if results.size > 1
            raise DuplicateCommuneError,
                  "Commune '#{identifier}' was found more than once for province: '#{province.name_en}'"
          end

          results.first
        end

        def scraper
          @scraper ||= WebScraper.new(URL)
        end
      end
    end
  end
end
