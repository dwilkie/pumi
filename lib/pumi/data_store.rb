module Pumi
  class DataStore
    def load(type, *args)
      Parser.new(type, *args).load
    end
  end
end
