require_relative "pumi/store_cache"
require_relative "pumi/data_store"

module Pumi
  class << self
    def data_store
      @data_store ||= reset_data_store!
    end

    private

    def reset_data_store!
      @data_store = StoreCache.new(DataStore.new)
    end
  end
end

require_relative "pumi/version"
require_relative "pumi/administrative_unit"
require_relative "pumi/location"
require_relative "pumi/province"
require_relative "pumi/district"
require_relative "pumi/commune"
require_relative "pumi/village"
require_relative "pumi/parser"
