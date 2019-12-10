module Pumi
  class DataStore
    def fetch(key, klass)
      Parser.new.load(key).each_with_object({}) do |(id, attributes), result|
        result[id] = klass.new(id, attributes)
      end
    end
  end
end
