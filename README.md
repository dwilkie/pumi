# Pumi - ភូមិ
[![Build Status](https://travis-ci.org/dwilkie/pumi.svg?branch=master)](https://travis-ci.org/dwilkie/pumi)

Provided Geodata for administrative regions in Cambodia.

![alt tag](https://raw.githubusercontent.com/dwilkie/pumi/master/pumi.jpg)

## Usage

### Rails

Using Pumi with Rails gives you some javascript helpers as well as an API to filter and select Provinces (ខេត្ត), Districts (ស្រុក / ខណ្ឌ), Communes (ឃុំ / សង្កាត់) and Villages (ភូមិ) in both English and Khmer, as seen below:

![alt tag](https://raw.githubusercontent.com/dwilkie/pumi/master/pumi_ui_en.jpg)
![alt tag](https://raw.githubusercontent.com/dwilkie/pumi/master/pumi_ui_km.jpg)

Require `"pumi/rails"` in your Gemfile:

```ruby
gem 'pumi', :github => "dwilkie/pumi", :require => "pumi/rails"
```

### Plain Ol' Ruby

Add this line to your application's Gemfile:

```ruby
gem 'pumi', :github => "dwilkie/pumi"
```

And then execute:

    $ bundle

Try the following:

    $ bundle exec irb

```ruby
  require 'pumi'

  # Working with Provinces (ខេត្ត)

  # Get all provinces
  Pumi::Province.all
  # => [#<Pumi::Province:0x005569528b4820 @id="01", @name_en="Banteay Meanchey", @name_km="បន្ទាយមានជ័យ">,...]

  # Find a province by id
  Pumi::Province.find_by_id("12")
  # => #<Pumi::Province:0x005569528b40a0 @id="12", @name_en="Phnom Penh", @name_km="ភ្នំពេញ">

  # Find a province by it's English name
  Pumi::Province.where(:name_en => "Phnom Penh")
  => [#<Pumi::Province:0x005569528b40a0 @id="12", @name_en="Phnom Penh", @name_km="ភ្នំពេញ">]

  # Find a province by it's Khmer name
  Pumi::Province.where(:name_km => "បន្ទាយមានជ័យ")
  # => [#<Pumi::Province:0x005569528b4820 @id="01", @name_en="Banteay Meanchey", @name_km="បន្ទាយមានជ័យ">]

  # Working with Districts (ស្រុក / ខណ្ឌ)

  # Get all districts
  Pumi::District.all
  # => [#<Pumi::District:0x0055695241b2f0 @id="0102", @name_en="Mongkol Borei", @name_km="មង្គលបូរី">, ...]

  # Get all districts by province_id
  Pumi::District.where(:province_id => "12")
  # => [#<Pumi::District:0x005569523f9b28 @id="1201", @name_en="Chamkar Mon", @name_km="ចំការមន">,...]

  # Find district by it's Khmer name and Province ID
  district = Pumi::District.where(:province_id => "12", :name_km => "ចំការមន").first
  # => #<Pumi::District:0x005569523f9b28 @id="1201", @name_en="Chamkar Mon", @name_km="ចំការមន">

  # Return the district's province name in English
  district.province.name_en
  # => Phnom Penh

  # Working with Communes (ឃុំ / សង្កាត់)

  # Get all communes by district_id
  Pumi::Commune.where(:district_id => "1201")
  # => [#<Pumi::Commune:0x0055695296ea90 @id="120101", @name_en="Tonle Basak", @name_km="ទន្លេបាសាក់">,...]

  # Find a commune by it's English name and District ID
  commune = Pumi::Commune.where(:district_id => "1201", :name_en => "Tonle Basak").first
  # => #<Pumi::Commune:0x0055695296ea90 @id="120101", @name_en="Tonle Basak", @name_km="ទន្លេបាសាក់">

  # Return the commune's district name in Khmer
  commune.district.name_km
  # => "ចំការមន"

  # Return the commune's province name in Khmer
  commune.province.name_km
  # => "ភ្នំពេញ"

  # Working with Villages (ភូមិ)

  # Get all villages by commune_id
  Pumi::Village.where(:commune_id => "010201")
  # => [#<Pumi::Village:0x005569545f1fa0 @id="01020101", @name_en="Ou Thum", @name_km="អូរធំ">,...]

  # Find a village by it's Khmer name and Commune ID
  village = Pumi::Village.where(:commune_id => "010201", :name_km => "អូរធំ").first
  # => #<Pumi::Village:0x005569545f1fa0 @id="01020101", @name_en="Ou Thum", @name_km="អូរធំ">

  # Return the village's commune name in English

  village.commune.name_en
  # => "Banteay Neang"

  # Return the village's district name in Khmer
  village.district.name_km
  => "មង្គលបូរី"

  # Return the village's province name in Khmer
  village.province.name_km
  # => "បន្ទាយមានជ័យ"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dwilkie/pumi.
