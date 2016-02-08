# Pumi - ភូមិ
[![Build Status](https://travis-ci.org/dwilkie/pumi.svg?branch=master)](https://travis-ci.org/dwilkie/pumi)

Contains Geodata for administrative regions in Cambodia.

![alt tag](https://raw.githubusercontent.com/dwilkie/pumi/master/pumi.jpg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pumi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pumi

## Usage

### Working with Provinces

```ruby
  require 'pumi'

  province = Pumi::Province.all.first
  # => #<Pumi::Province:0x0055b6c9a7cad0 @id="01", @locale="km", @attributes={"name_en"=>"Banteay Meanchey", "name_km"=>"បន្ទាយមានជ័យ"}>

  province.name
  # => "បន្ទាយមានជ័យ"

  province.name_kh
  # => "បន្ទាយមានជ័យ"

  province.name_en
  # => "Banteay Meanchey"

  province.id
  # => "01"

  Pumi::Province.all("en").first.name
  # => "Banteay Meanchey"

  Pumi::Province.find_by_id("01")
  # => #<Pumi::Province:0x0055b6c9a47470 @id="01", @locale="km", @attributes={"name_en"=>"Banteay Meanchey", "name_km"=>"បន្ទាយមានជ័យ"}>
```

### Working with Districts

```ruby
  require 'pumi'

  district = Pumi::District.all.first
  # => #<Pumi::District:0x0055b6c9a2a370 @id="0102", @locale="km", @attributes={"name_en"=>"Mongkol Borei", "name_km"=>"មង្គលបុរី"}>

  district.name
  # => "មង្គលបុរី"

  district.name_en
  # => "Mongkol Borei"

  district.id
  # => "0102"

  Pumi::District.all("en").first.name
  => "Mongkol Borei"

  Pumi::District.find_by_id("0102")
  # => #<Pumi::District:0x0055b6c9a029d8 @id="0102", @locale="km", @attributes={"name_en"=>"Mongkol Borei", "name_km"=>"មង្គលបុរី"}>
```

### Working with Communes

```ruby
  require 'pumi'

  commune = Pumi::Commune.all.first
  # => #<Pumi::Commune:0x0055b6c99cc0e0 @id="010201", @locale="km", @attributes={"name_en"=>"Banteay Neang", "name_km"=>"បន្ទាយនាង"}>

  commune.name
  # => "បន្ទាយនាង"

  commune.name_en
  # => "Banteay Neang"

  commune.id
  # => "010201"

  Pumi::Commune.all("en").first.name
  # => "Banteay Neang"

  Pumi::Commune.find_by_id("010201")
  # => #<Pumi::Commune:0x0055b6c99b6ce0 @id="010201", @locale="km", @attributes={"name_en"=>"Banteay Neang", "name_km"=>"បន្ទាយនាង"}>
```

### Working with Villages

```ruby
  require 'pumi'

  village = Pumi::Village.all.first
  # => #<Pumi::Village:0x0055697dbe3bd8 @id="01020101", @locale="km", @attributes={"name_en"=>"Ou Thum", "name_km"=>"អូរធំ"}>

  village.name
  # => "អូរធំ"

  village.name_en
  # => "Ou Thum"

  village.id
  # => "01020101"

  Pumi::Village.all("en").first.name
  # => "Ou Thum"

  Pumi::Village.find_by_id("01020101")
  # => #<Pumi::Village:0x0055697d613b18 @id="01020101", @locale="km", @attributes={"name_en"=>"Ou Thum", "name_km"=>"អូរធំ"}>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dwilkie/pumi.
